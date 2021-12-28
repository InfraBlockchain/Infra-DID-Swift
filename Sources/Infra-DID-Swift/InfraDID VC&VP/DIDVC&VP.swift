//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/12/01.
//

import Foundation
import PromiseKit

//Method: Create VC Based JWT

public func createVerifiableCredentialJwt(payload: CredentialPayload, issuer: JwtVcIssuer) async -> String {
  let jwtPayload: JwtCredentialPayload = transformCredentialInput(input: payload)
  
  guard let bool = try? await validateJwtCredentialPayload(payload: jwtPayload), bool else { return "" }
  
  let jsonData = try! JSONEncoder().encode(jwtPayload)
  guard let json = try? JSONDecoder().decode(JwtPayload.self, from: jsonData) else {
    return ""
  }
  
  return try! await createJwt(payload: json, jwtOptions: JwtOptions(issuer: issuer.did != "" ? issuer.did : jwtPayload.iss ?? "", canonicalize: false, signer: issuer.signer, alg: nil, expiresIn: nil), header: Header())
}

//Method: Create VP Based JWT

public func createVerifiablePresentationJwt(payload: PresentationPayload, holder: JwtVcIssuer, options: PresentationOptions = PresentationOptions()) async -> String {
  var jwtPayload: JwtPresentationPayload = transformPresentationInput(input: payload)
    
  if options.challenge != nil && jwtPayload.nonce == nil {
    jwtPayload.nonce = options.challenge
  }
  
  if options.domain != nil, let payloadAud = jwtPayload.aud {
    var aud = [options.domain!]
    aud += payloadAud
    jwtPayload.aud = aud
  }
  
  guard let bool = try? await validateJwtPresentationPayload(payload: jwtPayload), bool else { return "" }
  
  let jsonData = try! JSONEncoder().encode(jwtPayload)
  guard let json = try? JSONDecoder().decode(JwtPayload.self, from: jsonData) else {
    return ""
  }
  
  return try! await createJwt(payload: json, jwtOptions: JwtOptions(issuer: holder.did != "" ? holder.did : jwtPayload.iss ?? "", canonicalize: false, signer: holder.signer, alg: nil, expiresIn: nil), header: Header())
}


public func validateJwtPresentationPayload(payload: JwtPresentationPayload) async throws -> Bool  {
  guard let vp = payload.vp, vp.type.count != 0, vp.context.count != 0, vp.verifiableCredential.count != 0 else { throw JWTError(localizedDescription: "@context is missing default context")}
  
  let credential = vp.verifiableCredential.filter {(type(of: $0) is String.Type)}
  
  guard let jwt = credential.first else { throw JWTError(localizedDescription: "Not Exists verifiableCredential") }
  
  let a = "[a-zA-Z0-9_-]+"
  let part = jwt.matchingStrings(regex: "^\(a).\(a).?\(a)$")
  
  guard part[0].count != 0 else { throw JWTError(localizedDescription: "Jwt Format Error")}
  
  return true
}

public func validateJwtCredentialPayload(payload: JwtCredentialPayload) async throws -> Bool {

  guard let vc = payload.vc, vc.type.count != 0 , vc.context.count != 0, let _ = vc.credentialSubject.credentialValue as? [String:Any]  else {
    throw JWTError(localizedDescription: "Verifiable Credential Not Found")}
  
  guard payload.iss != nil, payload.nbf != nil else {
    throw JWTError(localizedDescription: "Payload Configuration Error")
  }
  
  return true
}

public func validateCredentialPayload(payload: CredentialPayload) throws -> Bool {
  
  guard payload.context.count != 0, payload.type.count != 0, let _ = payload.credentialSubject.credentialValue as? [String:Any]  else {
    throw JWTError(localizedDescription: "Verifiable Credential Not Found")}
  
  guard payload.issuanceDate != nil else {
    throw JWTError(localizedDescription: "Payload Configuration Error")
  }
  
  return true
}


public func verifyPresentationPayloadOptions(payload: JwtPayload, options: PresentationOptions) async throws  {
  if options.challenge != nil && payload.nonce != options.challenge {
    throw JWTError(localizedDescription: "Presentation does not contain the mandatory challenge")
  }
  
  if options.domain != nil {
    
    if payload.aud != nil {
      guard let aud = payload.aud else { return }
      
      let index = aud.firstIndex(of: options.domain!)
      
      guard index != nil else { throw JWTError(localizedDescription: "Presentation does not contain the mandatory domain (JWT: aud)")}
    }
  }
  
}


public func normalizedPresentation(jwt: String, removeOriginalFields: Bool = true) async throws -> PresentationPayload {
  if jwt != "" {
    let a = "[a-zA-Z0-9_-]+"
    let part = jwt.matchingStrings(regex: "^\(a).\(a).?\(a)$")
    
    guard part[0].count != 0 else { throw JWTError(localizedDescription: "Jwt Format Error")}
    
    return try! await normalizeJwtPresentation(input: jwt)
  } else {
    throw JWTError(localizedDescription: "jwt not is String")
  }
}

// DecodeJWT -> JwtPayload 로 변환하는 작업

public func normalizeJwtPresentation(input: String) async throws -> PresentationPayload {
  let decoded = decodeJwt(jwt: input)

  if decoded.payload.iss == nil { throw JWTError(localizedDescription: "not Found Did") }
  
  let decodedPayload = decoded.payload
  
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  encoder.dateEncodingStrategy = .secondsSince1970
  decoder.dateDecodingStrategy = .secondsSince1970
  
  guard let data = try? encoder.encode(decodedPayload),
        let jsonPayload = try? decoder.decode(JwtPayload.self, from: data) else {
          return PresentationPayload()
        }
  
  var payload = normalizeJwtPresentationPayload(input: jsonPayload)
  payload.proof = ["type": "JwtProof2020", "jwt": "\(input)"]
  return  payload
  
}
//JwtPayload -> PresentationPayload
public func normalizeJwtPresentationPayload(input: JwtPayload) -> PresentationPayload {
  let formatter = ISO8601DateFormatter()
  
  var payload: PresentationPayload = PresentationPayload() //initialized
  
  guard let vp = input.vp else { return PresentationPayload() }
  let vcJwt = vp.verifiableCredential.map {
    decodeJwt(jwt: $0)
  }
  
  payload.verifiableCredential = VerifiableCredentialType.credentialArray(
    vcJwt.enumerated().map {
      normalizeCredential(input: $0.element.payload, jwt: vp.verifiableCredential[$0.offset])
    }
  )
  
  if input.aud != nil {
    payload.verifier = input.aud!
  }
  
  payload.holder = input.iss ?? ""
  payload.type = vp.type
  payload.context = vp.context
  
  if let issDate = input.nbf {
    payload.issuanceDate = formatter.string(from: issDate)
  } else if let issDate = input.iat {
    payload.issuanceDate = formatter.string(from: issDate)
  }
  
  payload.expirationDate = formatter.string(from: input.exp!)
  
  return payload
}

public func normalizeCredential(input: JwtPayload, jwt: String) -> CredentialPayload {
  
  var credentialPayload = CredentialPayload()
  
  guard let vc = input.vc, let _ = input.sub,
        let iss = input.iss else { return CredentialPayload() }
  
  let formatter = ISO8601DateFormatter()
  
  credentialPayload.id = input.jti ?? nil
  credentialPayload.type = vc.type
  credentialPayload.credentialSubject = vc.credentialSubject
  credentialPayload.issuer = ["id": iss]
  credentialPayload.context = vc.context
  credentialPayload.proof = ["type": "JwtProof2020", "jwt": jwt]
  
  if let issDate = input.nbf {
    credentialPayload.issuanceDate = formatter.string(from: issDate)
  } else if let issDate = input.iat {
    credentialPayload.issuanceDate = formatter.string(from: issDate)
  }
  
  return credentialPayload
}

//exp check
private func validatePresentationPayload(payload: PresentationPayload) -> Bool {
  let formatter = ISO8601DateFormatter()
  let expDate = formatter.date(from: payload.expirationDate ?? "")
  
  let expCheck = expDate!.timeIntervalSinceNow > formatter.date(from: Date.now.ISO8601Format())!.timeIntervalSinceNow ? true : false
  
  return expCheck
}


//Verify VP & VC
public func verifyPresentation(presentation: String, resolver: Resolvable, options: PresentationOptions = PresentationOptions()) async -> VerifiedPresentation {
  
  guard let verified = try? verifyJwt(jwt: presentation, options: JwtVerifyOptions(proofPurpose: nil, audience: options.audience ?? nil, resolver: resolver)) else { return VerifiedPresentation()} // VerifyVpJwt

  var verifiedPresentation = VerifiedPresentation(verifiedJwt: verified, verifiablePresentation: PresentationPayload())

  try? await verifyPresentationPayloadOptions(payload: verified.payload!, options: options)
  
  guard let presentationPayload = try? await normalizedPresentation(jwt: verified.jwt) else { return VerifiedPresentation() }
  
  verifiedPresentation.verifiablePresentation = presentationPayload
  
  if options.vcValidateFlag { // Verify VC JWT in VP
    if let value = verifiedPresentation.verifiablePresentation.verifiableCredential.credentialValue as? [CredentialPayload]{
      for i in 0..<value.count {
        let verifiedCredential = verifyCredential(credential: value[i].proof["jwt"] ?? "", resolver: resolver)
        verifiedPresentation.verifiableCredentials.append(verifiedCredential)
      }
    }
  }
  
  return verifiedPresentation
}

//Parameter
// credential: VcJwt String
// resolver: Did Resolver
// options:

public func verifyCredential(credential: String, resolver: Resolvable, options: CredentialOptions = CredentialOptions()) -> VerifiedCredential {
  guard let verified = try? verifyJwt(jwt: credential, options: JwtVerifyOptions(proofPurpose: nil, audience: options.audience ?? nil, resolver: resolver)) else { return VerifiedCredential() }
  
  var verifiedCredential = VerifiedCredential(verifiedJwt: verified, verifiableCredential: CredentialPayload())
  
  verifiedCredential.verifiableCredential = normalizeCredential(input: verified.payload!, jwt: verified.jwt)
  
  guard let bool = try? validateCredentialPayload(payload: verifiedCredential.verifiableCredential), bool else { return VerifiedCredential() }
  
  return verifiedCredential
}
