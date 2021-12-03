//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/12/01.
//

import Foundation
import PromiseKit

//Method: Create VC Based JWT
public func createVerifiableCredentialJwt() {
  
}

//Method: Create VP Based JWT
@available(macOS 12, *)
public func createVerifiablePresentationJwt(payload: PresentationPayload, holder: JwtVcIssuer, options: CreatePresentationOptions = CreatePresentationOptions()) async -> String {
  //iPrint(payload)
  iPrint(holder)
  //let payload: PresentationPayload = transformPresentationInput(input: payload)
  var jwtPayload: JwtPresentationPayload = transformPresentationInput(input: payload)
  
  iPrint(jwtPayload)
  
  if options.challenge != nil && jwtPayload.nonce == nil {
    jwtPayload.nonce = options.challenge
  }
  
  if options.domain != nil, let payloadAud = jwtPayload.aud {
    var aud = [options.domain!]
    aud += payloadAud
    jwtPayload.aud = aud
  }
  
  let bool = try! await validateJwtPresentationPayload(payload: jwtPayload)
  
  guard bool else { return ""}
  
  let jsonData = try! jwtPayload.toJsonData(convertToSnakeCase: false, prettyPrinted: true)
  guard let json = try? JSONDecoder().decode(JwtPayload.self, from: jsonData) else {
    return ""
  }
  
  iPrint(json.exp)
  iPrint(json.iss)
  return try! await createJwt(payload: json, jwtOptions: JwtOptions(issuer: holder.did != "" ? holder.did : jwtPayload.iss ?? "", canonicalize: false, signer: holder.signer, alg: nil, expiresIn: nil), header: Header())
//  return Promise { seal in
//    firstly {
//      try! createJwt(payload: json, jwtOptions: JwtOptions(issuer: holder.did != "" ? holder.did : jwtPayload.iss ?? "", canonicalize: false, signer: holder.signer, alg: nil, expiresIn: nil), header: Header())
//    }.done { jwt in
//      seal.fulfill(jwt)
//    }
//  }
//  return Promise { seal in
//    firstly {
//      try! validateJwtPresentationPayload(payload: payload)
//    }.done {
//      let jsonData = try! payload.toJsonData()
//      guard let json = try? JSONDecoder().decode(JwtPayload.self, from: jsonData) else {
//        seal.reject(JWTError(localizedDescription: "payload Error"))
//      }
//
//      return
//    }
//  }
  
  //return try! createJwt(payload: json, jwtOptions: JwtOptions(issuer: holder.did != "" ? holder.did : jwtPayload.iss ?? "", canonicalize: false, signer: holder.signer, alg: nil, expiresIn: nil), header: Header())
//  try! validateJwtPresentationPayload(payload: payload) {
//    let jsonData = try! payload.toJsonData()
//    guard let json = try? JSONDecoder().decode(JwtPayload.self, from: jsonData) else {
//      return Promise<String>.value("")
//    }
//    return createJwt(payload: json, jwtOptions: JwtOptions(issuer: holder.did ?? payload.iss ?? "", canonicalize: false, signer: holder.signer, alg: nil, expiresIn: nil), header: Header())
//
//  }
}

public func validateJwtPresentationPayload(payload: JwtPresentationPayload) async throws -> Bool  {
  guard let vp = payload.vp, vp.type.count != 0, vp.context.count != 0, vp.verifiableCredential.count != 0 else { throw JWTError(localizedDescription: "@context is missing default context")}
  
  let credential = vp.verifiableCredential.filter {(type(of: $0) is String.Type)}
  
  guard let jwt = credential.first else { throw JWTError(localizedDescription: "Not Exists verifiableCredential") }
  
  let a = "[a-zA-Z0-9_-]+"
  let part = jwt.matchingStrings(regex: "^\(a).\(a).?\(a)$")
  
  guard part[0].count != 0 else { throw JWTError(localizedDescription: "Jwt Format Error")}
  
  return true
 // onCompleted()
}

public func verifyPresentation(presentation: String, resolver: Resolvable, options: VerifyPresentationOptions = VerifyPresentationOptions()) async -> VerifiedPresentation {
  verifyJwt(jwt: <#T##String#>, options: <#T##JwtVerifyOptions#>)
}
