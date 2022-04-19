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


private func decodeJws(jws: String) -> JwsDecoded {
  let pattern = "([a-zA-Z0-9_-]+)"
  let part = jws.matchingStrings(regex: "^\(pattern).\(pattern).\(pattern)$")[0]
  
  var decodeJws = JwsDecoded()
  
  if !part.isEmpty {
    decodeJws = JwsDecoded(header: Header(), payload: part[2], signature: part[3], data: "\(part[1])\(part[2])")
  }
  
  return decodeJws
}

/**
 Decodes a JWT and returns an object representing the payload
 
 - Parameter JwtString a JSON Web Token to verify

 - Throws: None
 
 - Returns: `JwtDecoded Struct` Object a JS object representing the decoded JWT
 
 */
public func decodeJwt(jwt: String) -> JwtDecoded {
  if jwt == "" { return JwtDecoded() }
  
  var decodeJwt = JwtDecoded()
  
  do {
    let jws = decodeJws(jws: jwt)
    
    let jsonEncoder = JSONEncoder()
    jsonEncoder.dataEncodingStrategy = .base64
    let baseData = base64urlDecodedData(base64urlEncoded: jws.payload)
    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = .secondsSince1970
    let data = try jsonDecoder.decode(JwtPayload.self, from: baseData ?? Data.init())
    decodeJwt = JwtDecoded(header: jws.header, payload: data, signature: jws.signature, data: jws.data)
  } catch (let err) {
    iPrint(err.localizedDescription)
  }
  return decodeJwt
}

/**
 Creates a signed JWS given a payload, a signer, and an optional header.
 
 - Parameter JwtPayload payload object
 - Parameter JWTSigner a signer, see `ES256KSigner`
 - Parameter Header optional object to specify or customize the JWS header
 
 - Throws: None
 
 - Returns: `JwsString` resolves with a JWS string or rejects with an error
 
 */
private func createJws(payload: JwtPayload, signer: JWTSigner, header: Header?) -> String {
  guard let header = header else { return ""}
  
  var jwt = JWT(header: header, claims: payload)
  guard let signedJwt: String = try? jwt.sign(using: signer) else { return "" }
  return signedJwt
}


/**
 Creates a signed JWT given an address which becomes the issuer, a signer, and a payload for which the signature is over.
 
 - Parameter JwtPayload payload object
 - Parameter JwtOptions an unsigned credential object
 - Parameter Header optional object to specify or customize the JWT header

 - Throws: None
 
 - Returns: `JwtString` a promise which resolves with a signed JSON Web Token
 
 */
public func createJwt(payload: JwtPayload, jwtOptions: JwtOptions, header: Header) -> String {
  var fullPayload: JwtPayload = payload
  //NSDate.now
  fullPayload.iat = NSDate.now//Date.now
  
  if jwtOptions.expiresIn != nil {
    
    let timestamps: Date  = (payload.nbf != nil) ? payload.nbf! : NSDate.now//Date.now
    
    fullPayload.exp = Date(timeIntervalSince1970: (floor(Double(timestamps.timeIntervalSinceNow) / 1000) + floor(jwtOptions.expiresIn!)))
  }
  
  guard let signer = jwtOptions.signer else { return ""}
  fullPayload.iss = jwtOptions.issuer
  
  var header = header
  
  if header.alg == "" { header.alg = defaultAlg }
  return createJws(payload: fullPayload, signer: signer, header: header)
}



/**
 Verifies given JWT. If the JWT is valid, the promise returns an object including the JWT, the payload of the JWT, and the did doc of the issuer of the JWT.
 
 - Parameter JwtString a JSON Web Token to verify
 - Parameter JwtVerifyOptions an unsigned credential object
 - Parameter `options.auth`  Require signer to be listed in the authentication section of the DID document (for Authentication purposes)
 - Parameter `options.audience` DID of the recipient of the JWT
 - Parameter `options.callbackUrl` callback url in JWT
 
 - Throws: `resolver error`
 - Throws: `invalid_jwt: JWT iss is required`
 - Throws: `invalid_jwt: JWT sub is required`
 - Throws: `invalid_jwt: JWT did is required`
 - Throws: `invalid_jwt: No DID has been found in the JWT`

 - Returns: `JwtVerified` resolves with a response object or rejects with an error
 
 */
public func verifyJwt(jwt: String, options: JwtVerifyOptions) throws -> JwtVerified {
  let jwtDecoded = decodeJwt(jwt: jwt)
  
  var proofPurpose: ProofPurposeTypes? = options.proofPurpose ?? nil

  guard let resolver = options.resolver else { throw JWTError(localizedDescription: "resolver error") }
  
  if options.auth != nil {
    proofPurpose = options.auth! ? ProofPurposeTypes.authentication : options.proofPurpose
  }
  
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
  
  guard let authenticator = try? resolveAuthenticator(resolver: resolver, alg: jwtDecoded.header.alg!, issuer: did, proofPurpose: proofPurpose ?? .authentication) else { return JwtVerified() }
  iPrint(authenticator)

  guard let verified = try? resolveVerified(authenticator: authenticator, jwt: jwt, jwtDecoded: jwtDecoded, options: options) else { return JwtVerified() }
  
  return verified

}


// MARK: resolveVerified
/**
 Resolves DID Authenticator
 
 - Parameter DIDAuthenticator
 - Parameter JwtString
 - Parameter JwtDecoded
 - Parameter JwtVerifyOptions
 
 - Throws: `not Found Key`
 - Throws: `not Verified Jwt`
 - Throws: `Nil Error`
 - Throws: `invalid_jwt: JWT not valid before nbf: \(nbf)`
 - Throws: `invalid_jwt: JWT not valid before iat: \(iat)`
 - Throws: `invalid_jwt: JWT not valid before exp: \(exp)`
 - Throws: `invalid_config: JWT audience is required but your app address has not been configured`
 
 - Returns: `JwtVerified`
 
 */
private func resolveVerified(authenticator: DIDAuthenticator, jwt: String, jwtDecoded: JwtDecoded, options: JwtVerifyOptions) throws -> JwtVerified {
  iPrint(jwtDecoded.payload)
  if authenticator.authenticators.count > 1 {
    iPrint(authenticator.authenticators)
  } else if authenticator.authenticators.count != 0 {
    guard let keyHex = authenticator.authenticators[0].publicKeyHex, let pubKey = try? Data(hex: keyHex) else { throw JWTError(localizedDescription: "not Found Key") }

    iPrint(pubKey.toEosioK1PublicKey)
    let verifier = JWTVerifier.es256(publicKey: pubKey)
    iPrint(authenticator.issuer)
    let isVerified = verifier.verify(jwt: jwt)
    
    guard isVerified else { throw JWTError(localizedDescription: "not Verified Jwt")}
  }
  
  let auth = authenticator.authenticators[0]
  
  let now = floor(Double(NSDate.now.timeIntervalSinceNow) / 1000)
  let skewTimes = options.skewTime != nil && options.skewTime! > 0 ? options.skewTime! : nbfSkew
  if auth.id != "" {
    let nowSkewed = now + skewTimes
    //1
    if jwtDecoded.payload.nbf != nil {
      guard let nbf = jwtDecoded.payload.nbf else { throw JWTError(localizedDescription: "Nil Error")}
      iPrint(floor(Double(nbf.timeIntervalSinceNow) / 1000))
      if floor(Double(nbf.timeIntervalSinceNow) / 1000) > nowSkewed {
        throw JWTError(localizedDescription: "invalid_jwt: JWT not valid before nbf: \(nbf)")
      }
    }
    //2
    else if jwtDecoded.payload.iat != nil {
      guard let iat = jwtDecoded.payload.iat else { throw JWTError(localizedDescription: "Nil Error")}
      if floor(Double(iat.timeIntervalSinceNow) / 1000) > nowSkewed {
        throw JWTError(localizedDescription: "invalid_jwt: JWT not valid before iat: \(iat)")
      }
    }
    
    
    if jwtDecoded.payload.exp != nil {
      guard let exp = jwtDecoded.payload.exp else { throw JWTError(localizedDescription: "Nil Error")}
      let expDouble = floor((Double(exp.timeIntervalSinceNow) / 1000))
      if expDouble <= now - skewTimes {
        throw JWTError(localizedDescription: "invalid_jwt: JWT not valid before exp: \(exp)")
      }
    }
    
    if jwtDecoded.payload.aud != nil {
      guard let _ = jwtDecoded.payload.aud else { throw JWTError(localizedDescription: "Nil Error")}
      
      if options.audience == nil && options.callbackUrl == nil {
        throw JWTError(localizedDescription: "invalid_config: JWT audience is required but your app address has not been configured")
      }
    }
  }
  return JwtVerified(didResolutionResult: authenticator.didResolutionResult, issuer: authenticator.issuer, signer: auth, jwt: jwt, payload: jwtDecoded.payload)
}


// MARK: resolveAuthenticator
/**
 Resolves relevant public keys or other authenticating material used to verify signature from the DID document of provided DID
 
 - Parameter Resolver
 - Parameter algorithm a JWT algorithm
 - Parameter issuer
 - Parameter ProofPurposeTypes

 - Throws: `not_supported: No supported signature types for algorithm`
 - Throws: `resolver_error: Unable to resolve DID document for \(issuer)`
 - Throws: `no_suitable_keys: DID document for \(issuer) does not have public keys suitable for \(alg) with \(proofPurpose.rawValue) purpose`
 
 - Returns: `DIDAuthenticator` resolves with a response object containing an array of authenticators or if non exist rejects with an error
 
 */
private func resolveAuthenticator(resolver: Resolvable, alg: String, issuer: String, proofPurpose: ProofPurposeTypes) throws -> DIDAuthenticator {
  let verifyType = alg != "" ? "EcdsaSecp256k1VerificationKey2019" : ""
  
  guard verifyType != "" else { throw JWTError(localizedDescription: "not_supported: No supported signature types for algorithm")}
  
  var didResult = DIDResolutionResult()
  var authenticator = DIDAuthenticator()
  
  let res = resolver.resolve(didUrl: issuer, options: DIDResolutionOptions(accept: didJson))
  
  if res.isFulfilled && res.value != nil {
    guard let result = res.value else { return DIDAuthenticator() }
    if result.didDocument == nil {
      didResult.didDocument = result.didDocument
    } else {
      didResult = result
    }
    
    if didResult.didResolutionMetadata.errorDescription != nil || didResult.didDocument == nil {
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
      }
      return method!
    }
    
    publicKeysCheck = publicKeysCheck.filter { $0.id != "" }
    
    let authenticators: [VerificationMethod] = publicKeysCheck.filter { $0.type == "EcdsaSecp256k1VerificationKey2019" }
    
    if authenticators.count == 0 {
      throw JWTError(localizedDescription: "no_suitable_keys: DID document for \(issuer) does not have public keys suitable for \(alg) with \(proofPurpose.rawValue) purpose")
    }
    
    authenticator =  DIDAuthenticator(authenticators: authenticators, issuer: issuer, didResolutionResult: didResult)

  }
  return authenticator
}

public func getPublicKeyById(verificationsMethods: [VerificationMethod], pubid: String? = nil) -> VerificationMethod? {
  let filtered = verificationsMethods.filter {$0.id == pubid}
  return filtered.count > 0 ? filtered[0] : nil
}
