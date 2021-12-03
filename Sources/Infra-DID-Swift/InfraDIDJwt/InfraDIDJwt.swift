//
//  File.swift
//
//
//  Created by SatGatLee on 2021/11/25.
//

import Foundation
import PromiseKit
import EosioSwiftEcc


public let selfIssuedV2 = "https://self-issued.me/v2"
public let selfIssuedV1 = "https://self-issued.me"
fileprivate let defaultAlg = "ES256K"
fileprivate let didJson = "application/did+json"
public let nbfSkew: Double = 300


public func encodeSection(data: Any, shouldCanonicalize: Bool = false) -> String { // data to encodeBase64URL
  if shouldCanonicalize {
    return ""
  } else {
    return ""
  }
}

func decodeJws(jws: String) -> JwsDecoded {
  let a = "([a-zA-Z0-9_-]+)"
  let part = jws.matchingStrings(regex: "^\(a).\(a).\(a)$")[0]
  //let part = jws.matchingStrings(regex: "^\(a)\.\(b)\.\(c)$")
  var decodeJws = JwsDecoded()
  //let part = parts[0]
  iPrint(part)
  if !part.isEmpty {
    decodeJws = JwsDecoded(header: Header(), payload: part[2], signature: part[3], data: "\(part[1])\(part[2])")
  }
  //let parts = try! jws.matchingStrings(regex: "^([a-zA-Z0-9_-]+)\.([a-zA-Z0-9_-]+)\.([a-zA-Z0-9_-]+)$")[0]
  //Header()
  return decodeJws
}

public func decodeJwt(jwt: String) -> JwtDecoded { //jwt값을 decode하고 그 안의 payload를 디코딩해서 json 형태로 파싱하고 객체에 복사한다.
  if jwt == "" { NSError.init().localizedDescription }
  var decodeJwt = JwtDecoded()
  do {
    let jws = decodeJws(jws: jwt)
    
    
    guard let baseData = base64urlDecodedData(base64urlEncoded: jws.payload) else { return JwtDecoded() }
    //    let jwsDecod = [UInt8](baseData)
    //    iPrint(jwsDecoded.toJsonString())
    iPrint(baseData)
    let data = try JSONDecoder().decode(JwtPayload.self, from: baseData)
    iPrint(data)
    decodeJwt = JwtDecoded(header: jws.header, payload: data, signature: jws.signature, data: jws.data)
  } catch (let err) {
    iPrint(err.localizedDescription)
  }
  return decodeJwt
}

public enum PayloadType {
  case string(String)
  case jwtPayload(JwtPayload?)
}

public func createJws(payload: JwtPayload, signer: JWTSigner, header: Header?, options: JwsCreationOptions) async -> String {
  guard let header = header else { return ""}
  
  //  let encodedPayload = type(of: payload) == String ? payload : encodeSection(data: payload, shouldCanonicalize: options.canonicalize)
  //  let signingInput: String = [encodeSection(data: header, shouldCanonicalize: options.canonicalize), encodedPayload].joined(separator: ".")
  
  let encodedHeader = try! header.encode()
  let encodedPayload = try! payload.encode()
  //JWT(header: <#T##Header#>, claims: <<error type>>)
  //let jwtSigner: SignerAlgorithm = SignerAlg(header.alg)
  
  //payload를 Json Object로 만들어야한다.
  let jsonClaims = try! payload.toJsonData(convertToSnakeCase: false, prettyPrinted: true)
  iPrint(jsonClaims)
  var jwt = JWT(header: header, claims: payload)
  return try! await jwt.sign(using: signer)
//  return Promise { seal in
//    firstly {
//      try! jwt.sign(using: signer)
//    }.done({ signature in
//      iPrint(signature)
//      seal.fulfill(signature)
//    })
//  }
}

@available(macOS 12, *)
public func createJwt(payload: JwtPayload, jwtOptions: JwtOptions, header: Header) async throws -> String {
  var fullPayload: JwtPayload = payload
  fullPayload.iat = Date.now
  
  
  iPrint(payload)
  if jwtOptions.expiresIn != nil {
    //let nbf: Bool = (payload.nbf != nil) || (fullPayload.iat != nil)
    
    let timestamps: Date  = (payload.nbf != nil) ? payload.nbf! : Date.now
    
    fullPayload.exp = Date(timeIntervalSinceNow: (floor(Double(timestamps.timeIntervalSinceNow) / 1000) + floor(jwtOptions.expiresIn!)))
  }
  
  
  guard let signer = jwtOptions.signer else { return ""}
  fullPayload.iss = jwtOptions.issuer
  
  var header = header
  
  if header.alg == "" { header.alg = defaultAlg }
  return await createJws(payload: fullPayload, signer: signer, header: header, options: JwsCreationOptions(canonicalize: jwtOptions.canonicalize))
//  return Promise { seal in
//    firstly {
//      createJws(payload: fullPayload, signer: signer, header: header, options: JwsCreationOptions(canonicalize: jwtOptions.canonicalize))
//    }.done { signature in
//      seal.fulfill(signature)
//    }
//  }
  //createJws(payload: fullPayload, signer: signer, header: header, options: JwsCreationOptions(canonicalize: jwtOptions.canonicalize))
}

//public func verifyJwsDecoded(decode: JwsDecoded, pubKeys: [VerificationMethod]) -> VerificationMethod {
//  
//}
//
//public func verifyJws() {
//  
//}

@available(macOS 12, *)
public func verifyJwt(jwt: String, options: JwtVerifyOptions) async throws -> JwtVerified {
  let jwtDecoded = decodeJwt(jwt: jwt)
  
  guard let auth = options.auth, let resolver = options.resolver, let skewTime = options.skewTime,
        let alg = jwtDecoded.header.alg else { throw JWTError(localizedDescription: "auth error")}
  
  let proofPurpose = auth ? ProofPurposeTypes.authentication : options.proofPurpose
  
  if jwtDecoded.payload.iss == nil {
    throw JWTError(localizedDescription: "invalid_jwt: JWT iss is required")
  }
  
  var did = ""
  
  if jwtDecoded.payload.iss == selfIssuedV2 {
    if jwtDecoded.payload.sub == nil {
      throw JWTError(localizedDescription: "invalid_jwt: JWT sub is required")
    }
  
    did = jwtDecoded.payload.sub != nil ? jwtDecoded.payload.sub ?? "" : String((jwtDecoded.header.kid?.split(separator: "#")[0])!)
  }
  else if jwtDecoded.payload.iss == selfIssuedV1 {
    if jwtDecoded.payload.did == nil {
      throw JWTError(localizedDescription: "invalid_jwt: JWT did is required")
    }
    did = jwtDecoded.payload.did ?? ""
  } else {
    did = jwtDecoded.payload.iss ?? ""
  }
  
  if did == "" {
    throw JWTError(localizedDescription: "invalid_jwt: No DID has been found in the JWT")
  }
  
  ///resolve 이후 jwt verify
  return Promise { seal in
    firstly {
      try! resolveAuthenticator(resolver: resolver, alg: jwtDecoded.header.alg!, issuer: did, proofPurpose: proofPurpose)
    }.done { authenticator in
     // let verifier = JWTVerifier(verifierAlgorithm: authenticator.authenticators)
      
      if authenticator.authenticators.count > 1 {
        iPrint(authenticator.authenticators)
      } else if authenticator.authenticators.count != 0 {
        guard let keyHex = authenticator.authenticators[0].publicKeyHex else { throw JWTError(localizedDescription: "not Found Key")}
        let pubKey = try! Data(hex: keyHex)
        let verifier = JWTVerifier.es256(publicKey: pubKey)
        
        let isVerified = verifier.verify(jwt: jwt)
        
        guard isVerified else { throw JWTError(localizedDescription: "not Verified Jwt")}
      }
      
      let auth = authenticator.authenticators[0]
//      let signer = verifyJwsDecoded(decode: JwsDecoded(header: jwtDecoded.header, payload: "", signature: jwtDecoded.signature, data: jwtDecoded.data), pubKeys: authenticator.authenticators.)
//      signer.publicKeyHex
      
      let now = floor(Double(Date.now.timeIntervalSinceNow) / 1000)
      let skewTimes = skewTime > 0 ? skewTime : nbfSkew
      
      if auth.id != "" {
        let nowSkewed = now + skewTime
        //1
        if jwtDecoded.payload.nbf != nil {
          guard let nbf = jwtDecoded.payload.nbf else { throw JWTError(localizedDescription: "Nil Error")}
          if floor(Double(nbf.timeIntervalSinceNow)) > nowSkewed {
            throw JWTError(localizedDescription: "invalid_jwt: JWT not valid before nbf: \(nbf)")
          }
        }
        //2
        else if jwtDecoded.payload.iat != nil {
          guard let iat = jwtDecoded.payload.iat else { throw JWTError(localizedDescription: "Nil Error")}
          if floor(Double(iat.timeIntervalSinceNow)) > nowSkewed {
            throw JWTError(localizedDescription: "invalid_jwt: JWT not valid before iat: \(iat)")
          }
        }
        
        
        if jwtDecoded.payload.exp != nil {
          guard let exp = jwtDecoded.payload.exp else { throw JWTError(localizedDescription: "Nil Error")}
          let expDouble = floor((Double(exp.timeIntervalSinceNow) / 1000))
          if expDouble <= now - skewTime {
            throw JWTError(localizedDescription: "invalid_jwt: JWT not valid before exp: \(exp)")
          }
        }
        
        if jwtDecoded.payload.aud != nil {
          guard let aud = jwtDecoded.payload.aud else { throw JWTError(localizedDescription: "Nil Error")}
          
          if options.audience == nil && options.callbackUrl == nil {
            throw JWTError(localizedDescription: "invalid_config: JWT audience is required but your app address has not been configured")
          }
        }
        
        seal.fulfill(JwtVerified(didResolutionResult: authenticator.didResolutionResult, issuer: authenticator.issuer, signer: auth, jwt: jwt))
      }
    }.catch { err in
      iPrint(err)
    }
  }
}


public func resolveAuthenticator(resolver: Resolvable, alg: String, issuer: String, proofPurpose: ProofPurposeTypes) async throws -> DIDAuthenticator {
  let verifyType = alg != "" ? "EcdsaSecp256k1VerificationKey2019" : ""
  
  guard verifyType != "" else { throw JWTError(localizedDescription: "not_supported: No supported signature types for algorithm")}
  
  var didResult = DIDResolutionResult()
  
  return Promise { seal in
    firstly {
      resolver.resolve(didUrl: issuer, options: DIDResolutionOptions(accept: didJson))
    }.done ({ result in
      if result.didDocument == nil {
        didResult.didDocument = result.didDocument
      } else {
        didResult = result
      }
      
      if didResult.didResolutionMetadata.errorDescription == nil || didResult.didDocument == nil {
        throw JWTError(localizedDescription: "resolver_error: Unable to resolve DID document for \(issuer)")
      }
      
      var publicKeysCheck: [VerificationMethod] = didResult.didDocument?.verificationMethod?.count != 0 ? (didResult.didDocument?.verificationMethod)! : (didResult.didDocument?.publicKey)!
      
      if proofPurpose == .assertionMethod && didResult.didDocument?.assertionMethod.count == 0{
        didResult.didDocument?.assertionMethod = publicKeysCheck.map {$0.id}
      }
      
      
      publicKeysCheck.map { verify -> VerificationMethod in
        var method: VerificationMethod? = nil
        switch proofPurpose {
        case .assertionMethod:
          method = getPublicKeyById(verificationsMethods: publicKeysCheck, pubid: didResult.didDocument?.assertionMethod.first ?? nil)
        case .capabilityDelegation:
          method = getPublicKeyById(verificationsMethods: publicKeysCheck, pubid: didResult.didDocument?.capabilityDelegation.first ?? nil)
        case .capabilityInvocation:
          method = getPublicKeyById(verificationsMethods: publicKeysCheck, pubid: didResult.didDocument?.capabilityInvocation.first ?? nil)
        case .authentication:
          method = getPublicKeyById(verificationsMethods: publicKeysCheck, pubid: didResult.didDocument?.authentication.first ?? nil)
//        case .none:
//          break
        }
        return method!
      }
      
      publicKeysCheck = publicKeysCheck.filter { $0.id != "" }
      
      let authenticators: [VerificationMethod] = publicKeysCheck.filter { $0.type == "EcdsaSecp256k1VerificationKey2019" }
      
      if authenticators.count == 0 {
        throw JWTError(localizedDescription: "no_suitable_keys: DID document for \(issuer) does not have public keys suitable for \(alg) with \(proofPurpose.rawValue) purpose")
      }
      seal.fulfill(DIDAuthenticator(authenticators: authenticators, issuer: issuer, didResolutionResult: didResult))
    })
  }
}

public func getPublicKeyById(verificationsMethods: [VerificationMethod], pubid: String? = nil) -> VerificationMethod? {
  let filtered = verificationsMethods.filter {$0.id == pubid}
  return filtered.count > 0 ? filtered[0] : nil
}
