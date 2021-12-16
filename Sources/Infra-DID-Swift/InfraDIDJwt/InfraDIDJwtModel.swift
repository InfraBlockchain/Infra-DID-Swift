
////
////  File.swift
////  
////
////  Created by SatGatLee on 2021/11/26.
////
//
import Foundation
import PromiseKit
import EosioSwiftEcc

public enum ProofPurposeTypes: String {
  case assertionMethod = "assertionMethod"
  case authentication = "authentication"
  case capabilityDelegation = "capabilityDelegation"
  case capabilityInvocation = "capabilityInvocation"
}

public enum SignerInputData {
  case string(String)
  case array([UInt8])
}

public enum SignerResult {
  case signature(EcdsaSignature)
  case string(String)
}

//public typealias Signer = (data: SignerInputData) -> Promise<SignerResult>
//public typealias SignerAlgorithm = (payload: String, signer: Signer) -> Promise<String>

public struct JwtOptions {
  var issuer: String
  var signer: JWTSigner?
  var alg: String?
  var expiresIn: Double?
  var canonicalize: Bool
  
  public init(issuer: String = "", canonicalize: Bool = false, signer: JWTSigner? = nil, alg: String? = nil, expiresIn: Double? = nil) {
    self.issuer = issuer
    self.canonicalize = canonicalize
    self.signer = signer
    self.alg = alg
    self.expiresIn = expiresIn
    //self.signer = signer
  }
}

public struct JwtVerifyOptions {
  var auth: Bool?
  var audience: String?
  var callbackUrl: String?
  var resolver: Resolvable?
  var skewTime: Double?
  var proofPurpose: ProofPurposeTypes?
  
  public init(proofPurpose: ProofPurposeTypes? = nil, audience: String? = nil,
              resolver: Resolvable? = nil) {
    self.proofPurpose = proofPurpose
    self.audience = audience
    self.resolver = resolver
  }
}

public struct JwsCreationOptions {
  var canonicalize: Bool?
}

public struct DIDAuthenticator {
  var authenticators: [VerificationMethod]
  var issuer: String
  var didResolutionResult: DIDResolutionResult
  
  public init(authenticators: [VerificationMethod] = [], issuer: String = "", didResolutionResult: DIDResolutionResult = DIDResolutionResult()) {
    
    self.authenticators = authenticators
    self.issuer = issuer
    self.didResolutionResult = didResolutionResult
  }
}
//
public struct JwtHeader {
  var type: String = "JWT"
  var alg: String
  //var
  
  public init(alg: String = "") {
    self.alg = alg
  }
}


public enum JwtPayloadAudienceType: Codable {
  case string(String)
  case array([String])
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let x = try? container.decode(String.self) {
      self = .string(x)
      return
    }
    if let x = try? container.decode([String].self) {
      self = .array(x)
      return
    }
    throw DecodingError.typeMismatch(JwtPayloadAudienceType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for audience"))
  }
}

//VC Payload
public struct JwtPayload: Claims {
  var iss: String?
  var sub: String?
  var aud: [String]?
  public var iat: Date?
  public var nbf: Date?
  public var exp: Date?
  var rexp: Double?
  //var requested: [String]
  //var subJwk: [String:Any]?
  var did: String?
  //var claim: T
  var jti: String?
  var vc: VerifiableCredentialObject?
  var vp: VerifiablePresentationObject?
  var nonce: String?
  
  enum CodingKeys:  String, CodingKey {
    case iss, sub, aud, iat, nbf, exp, rexp, did, vc, vp, nonce
    //case subJwk = "sub_jwk"
  }
  
  public init(iat: Date? = nil, iss: String? = "", sub: String? = "", nbf: Date? = nil,
              exp: Date? = nil, rexp: Double? = nil,
              aud: [String]? = nil, did: String? = nil, vc: VerifiableCredentialObject? = nil, vp: VerifiablePresentationObject? = nil,
              nonce: String? = nil) {
    //self.requested = requested
    self.iat = iat
    self.iss = iss
    self.sub = sub
    self.nbf = nbf
    self.exp = exp
    self.rexp = rexp
    self.aud = aud
    //self.subJwk = subJwk
    self.did = did
    //self.claim = claim
    self.vc = vc
    self.vp = vp
    self.nonce = nonce
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    iPrint(values)
    iss = (try? values.decode(String.self, forKey: .iss)) ?? nil
    sub = (try? values.decode(String.self, forKey: .sub)) ?? nil
    exp = (try? values.decode(Date.self, forKey: .exp)) ?? nil
    aud = (try? values.decode([String].self, forKey: .aud)) ?? nil
    iat = (try? values.decode(Date.self, forKey: .iat)) ?? nil
    nbf = (try? values.decode(Date.self, forKey: .nbf)) ?? nil
    rexp = (try? values.decode(Double.self, forKey: .rexp)) ?? nil
   // requested = (try? values.decode([String].self, forKey: .requested)) ?? []
    did = (try? values.decode(String.self, forKey: .did)) ?? nil
    //subJwk = (try? values.decode([String:Any].self, forKey: .subJwk)) ?? nil
    vc = (try? values.decode(VerifiableCredentialObject.self, forKey: .vc)) ?? nil
    vp = (try? values.decode(VerifiablePresentationObject.self, forKey: .vp)) ?? nil
    nonce = (try? values.decode(String.self, forKey: .vp)) ?? nil
  }
  
  func encode(from encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.iss, forKey: .iss)
    try container.encode(self.iat, forKey: .iat)
    try container.encode(self.sub, forKey: .sub)
    try container.encode(self.exp, forKey: .exp)
    try container.encode(self.rexp, forKey: .rexp)
    //try container.encode(self.requested, forKey: .requested)
    try container.encode(self.aud, forKey: .aud)
    try container.encode(self.nbf, forKey: .nbf)
    try container.encode(self.did, forKey: .did)
    try container.encode(self.vc, forKey: .vc)
    try container.encode(self.vp, forKey: .vp)
    try container.encode(self.nonce, forKey: .nonce)
  }
  //JSONEncoder()
}

//
public struct JwtDecoded {
  var header: Header
  var payload: JwtPayload
  var signature: String
  var data: String
  
  public init(header: Header = Header(), payload: JwtPayload = JwtPayload(), signature: String = "", data: String = "") {
    self.header = header
    self.payload = payload
    self.signature = signature
    self.data = data
  }
}


public struct JwsDecoded {
  var header: Header
  var payload: String
  var signature: String
  var data: String
  
  public init(header: Header = Header(), payload: String = "", signature: String = "", data: String = "") {
    self.header = header
    self.payload = payload
    self.signature = signature
    self.data = data
  }
}

public struct JwtVerified: Codable {
  var payload: JwtPayload?
  var didResolutionResult: DIDResolutionResult
  var issuer: String
  var signer: VerificationMethod
  var jwt: String
  
  public enum CodingKeys: CodingKey {
    case payload, didResolutionResult, issuer, signer, jwt
  }
  public init(didResolutionResult: DIDResolutionResult = DIDResolutionResult(), issuer: String = "", signer: VerificationMethod = VerificationMethod(), jwt: String = "", payload: JwtPayload? = nil) {
    self.didResolutionResult = didResolutionResult
    self.issuer = issuer
    self.signer = signer
    self.jwt = jwt
    self.payload = payload
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    payload = (try? values.decode(JwtPayload.self, forKey: .payload)) ?? nil
    didResolutionResult = (try? values.decode(DIDResolutionResult.self, forKey: .didResolutionResult)) ?? DIDResolutionResult()
    issuer = (try? values.decode(String.self, forKey: .issuer)) ?? ""
    signer = (try? values.decode(VerificationMethod.self, forKey: .signer)) ?? VerificationMethod()
    jwt = (try? values.decode(String.self, forKey: .jwt)) ?? ""


  }
  
  func encode(from encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.payload, forKey: .payload)
    try container.encode(self.didResolutionResult, forKey: .didResolutionResult)
    try container.encode(self.issuer, forKey: .issuer)
    try container.encode(self.signer, forKey: .signer)
    try container.encode(self.jwt, forKey: .jwt)
  }
}

public struct LegacyVerificationMethod {
  var publicKey: String?
}

//public struct PublicKeyTypes { //ES256K : EcdsaSecp256k1VerificationKey2019
//  var name: [String:[String]]
//  
//  public init(name: [String:[String]] = []) {
//    self.name = name
//  }
//}

