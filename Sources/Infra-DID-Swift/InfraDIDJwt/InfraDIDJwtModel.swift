
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

public struct DIDAuthenticator {
  public var authenticators: [VerificationMethod]
  public var issuer: String
  public var didResolutionResult: DIDResolutionResult
  
  public init(authenticators: [VerificationMethod] = [], issuer: String = "", didResolutionResult: DIDResolutionResult = DIDResolutionResult()) {
    
    self.authenticators = authenticators
    self.issuer = issuer
    self.didResolutionResult = didResolutionResult
  }
}

public struct JwtPayload: Claims {
  public var iss: String?
  public var sub: String?
  public var aud: [String]?
  public var iat: Date?
  public var nbf: Date?
  public var exp: Date?
  public var rexp: Double?
  //var requested: [String]
  //var subJwk: [String:Any]?
  public var did: String?
  //var claim: T
  public var jti: String?
  public var vc: VerifiableCredentialObject?
  public var vp: VerifiablePresentationObject?
  public var nonce: String?
  
  enum CodingKeys:  String, CodingKey {
    case iss, sub, aud, iat, nbf, exp, rexp, did, vc, vp, nonce
  }
  
  public init(iat: Date? = nil, iss: String? = "", sub: String? = "", nbf: Date? = nil,
              exp: Date? = nil, rexp: Double? = nil,
              aud: [String]? = nil, did: String? = nil, vc: VerifiableCredentialObject? = nil, vp: VerifiablePresentationObject? = nil,
              nonce: String? = nil) {
    self.iat = iat
    self.iss = iss
    self.sub = sub
    self.nbf = nbf
    self.exp = exp
    self.rexp = rexp
    self.aud = aud
    self.did = did
    self.vc = vc
    self.vp = vp
    self.nonce = nonce
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    iss = (try? values.decode(String.self, forKey: .iss)) ?? nil
    sub = (try? values.decode(String.self, forKey: .sub)) ?? nil
    exp = (try? values.decode(Date.self, forKey: .exp)) ?? nil
    aud = (try? values.decode([String].self, forKey: .aud)) ?? nil
    iat = (try? values.decode(Date.self, forKey: .iat)) ?? nil
    nbf = (try? values.decode(Date.self, forKey: .nbf)) ?? nil
    rexp = (try? values.decode(Double.self, forKey: .rexp)) ?? nil
    did = (try? values.decode(String.self, forKey: .did)) ?? nil
    vc = (try? values.decode(VerifiableCredentialObject.self, forKey: .vc)) ?? nil
    vp = (try? values.decode(VerifiablePresentationObject.self, forKey: .vp)) ?? nil
    nonce = (try? values.decode(String.self, forKey: .vp)) ?? nil
  }
  
  public func encode(from encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.iss, forKey: .iss)
    try container.encode(self.iat, forKey: .iat)
    try container.encode(self.sub, forKey: .sub)
    try container.encode(self.exp, forKey: .exp)
    try container.encode(self.rexp, forKey: .rexp)
    try container.encode(self.aud, forKey: .aud)
    try container.encode(self.nbf, forKey: .nbf)
    try container.encode(self.did, forKey: .did)
    try container.encode(self.vc, forKey: .vc)
    try container.encode(self.vp, forKey: .vp)
    try container.encode(self.nonce, forKey: .nonce)
  }
}

public struct JwtDecoded {
  public var header: Header
  public var payload: JwtPayload
  public var signature: String
  public var data: String
  
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
  
  public func encode(from encoder: Encoder) throws {
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
