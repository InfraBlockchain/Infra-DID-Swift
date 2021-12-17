//
//  File.swift
//
//
//  Created by SatGatLee on 2021/12/01.
//

import Foundation
//types, Converters, validators Integration



public struct CredentialStatus: Codable {
  var id: String
  var type: String
  
  public init(id: String = "", type: String = "") {
    self.id = id
    self.type = type
  }
}


public enum EvidenceType: Codable {
  case string(String)
  case dic([String:String])
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let x = try? container.decode(String.self) {
      self = .string(x)
      return
    }
    if let x = try? container.decode([String:String].self) {
      self = .dic(x)
      return
    }
    throw DecodingError.typeMismatch(EvidenceType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for EvidenceValue"))
  }
}

public struct VerifiableCredentialObject: Codable { //first jwt decoded vc
  var context: [String]
  var type: [String]
  var credentialSubject: [String:String]
  
  public enum CodingKeys: String, CodingKey {
    case context = "@context"
    case type, credentialSubject
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    context = (try? values.decode([String].self, forKey: .context)) ?? []
    type = (try? values.decode([String].self, forKey: .type)) ?? []
    credentialSubject = (try? values.decode([String:String].self, forKey: .credentialSubject)) ?? [:]
    
  }
  
  public func encode(from encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.context, forKey: .context)
    try container.encode(self.type, forKey: .type)
    try container.encode(self.credentialSubject, forKey: .credentialSubject)
  }
  
}


//public struct JwtCredentialPayload {
//  var iss: String?
//  var sub: String?
//  var vc: VerifiableCredentialObject
//  var nbf: Double?
//  var aud: contextType?
//  var exp: Double?
//  var jtl: String?
//  //extensible Object
//}

public enum DateType {
  case string(String)
  case date(Date)
}

public typealias SubjectType = Dictionary<String, Any>

public struct CredentialPayload: Codable { // organic struct add payload after verify Credential
  var context: [String]
  var id: String?
  var type: [String]
  var issuer: [String:String]
  var issuanceDate: String?
  var expirationDate: String?
  var credentialSubject: [String:String]
  var credentialStatus: CredentialStatus
  var evidence: EvidenceType?
  var termsOfUse: EvidenceType?
  var proof = [String:String]()
  
  public enum CodingKeys: String, CodingKey {
    case context = "@context"
    case id, type, issuer, issuanceDate, expirationDate, credentialSubject, credentialStatus, evidence, termsOfUse, proof
  }
  
  public init(context: [String] = [], id: String? = nil, type: [String] = [] ,
              issuer: [String:String] = [:], issuanceDate: String? = nil, expirationDate: String? = nil,
              credentialSubject: [String:String] = [:], credentialStatus: CredentialStatus = CredentialStatus(),
              evidence: EvidenceType? = nil, termsOfUse: EvidenceType? = nil) {
    self.context = context
    self.id = id
    self.type = type
    self.issuer = issuer
    self.issuanceDate = issuanceDate
    self.evidence = evidence
    self.expirationDate = expirationDate
    self.credentialSubject = credentialSubject
    self.credentialStatus = credentialStatus
    self.termsOfUse = termsOfUse
  }
  
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    context = (try? values.decode([String].self, forKey: .context)) ?? []
    type = (try? values.decode([String].self, forKey: .type)) ?? []
    id = (try? values.decode(String.self, forKey: .id)) ?? nil
    issuer = (try? values.decode([String:String].self, forKey: .issuer)) ?? [:]
    credentialStatus = (try? values.decode(CredentialStatus.self, forKey: .credentialStatus)) ?? CredentialStatus()
    issuanceDate = (try? values.decode(String.self, forKey: .issuanceDate)) ?? nil
    expirationDate = (try? values.decode(String.self, forKey: .expirationDate)) ?? nil
    credentialSubject = (try? values.decode([String:String].self, forKey: .credentialSubject)) ?? [:]
    proof = (try? values.decode([String:String].self, forKey: .proof)) ?? [:]
    evidence = (try? values.decode(EvidenceType.self, forKey: .proof)) ?? EvidenceType.string("")
    termsOfUse = (try? values.decode(EvidenceType.self, forKey: .proof)) ?? EvidenceType.string("")
  }
  
  public func encode(from encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.context, forKey: .context)
    try container.encode(self.type, forKey: .type)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.issuer, forKey: .issuer)
    try container.encode(self.credentialSubject, forKey: .credentialSubject)
    try container.encode(self.credentialStatus, forKey: .credentialStatus)
    try container.encode(self.issuanceDate, forKey: .issuanceDate)
    try container.encode(self.expirationDate, forKey: .expirationDate)
    try container.encode(self.proof, forKey: .proof)
    try container.encode(self.evidence, forKey: .evidence)
    try container.encode(self.termsOfUse, forKey: .termsOfUse)
  }
}

public struct VerifiedCredential: Codable { //검증끝난 전체 데이터 구조
  var verifiedJwt: JwtVerified
  var verifiableCredential: CredentialPayload
  
  public init(verifiedJwt: JwtVerified = JwtVerified(), verifiableCredential: CredentialPayload = CredentialPayload()) {
    self.verifiedJwt = verifiedJwt
    self.verifiableCredential = verifiableCredential
  }
}

public struct VerifiedPresentation: Codable {
  var verifiedJwt: JwtVerified
  var verifiablePresentation: PresentationPayload
  var verifiableCredentials: [VerifiedCredential] // Verified Result vc in vp
  
  public enum CodingKeys: CodingKey {
    case verifiedJwt, verifiablePresentation, verifiableCredentials
  }
  
  public init(verifiedJwt: JwtVerified = JwtVerified(), verifiablePresentation: PresentationPayload = PresentationPayload(),
              verifiableCredentials: [VerifiedCredential] = []) {
    self.verifiedJwt = verifiedJwt
    self.verifiablePresentation = verifiablePresentation
    self.verifiableCredentials = verifiableCredentials
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    verifiedJwt = (try? values.decode(JwtVerified.self, forKey: .verifiedJwt)) ?? JwtVerified()
    verifiablePresentation = (try? values.decode(PresentationPayload.self, forKey: .verifiablePresentation)) ?? PresentationPayload()
    verifiableCredentials = (try? values.decode([VerifiedCredential].self, forKey: .verifiableCredentials)) ?? []
    
  }
  
  public func encode(from encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.verifiablePresentation, forKey: .verifiablePresentation)
    try container.encode(self.verifiedJwt, forKey: .verifiedJwt)
    try container.encode(self.verifiableCredentials, forKey: .verifiableCredentials)
    
  }
}


public struct VerifiablePresentationObject: Codable {
  var context: [String]
  var type: [String]
  var verifiableCredential: [String]
  
  public enum CodingKeys: String, CodingKey {
    case context = "@context"
    case type, verifiableCredential
  }
}

//
public enum VerifiableCredentialType: Codable {
  case string([String])
  case credential(CredentialPayload) //Only VerifyCredential
  case credentialArray([CredentialPayload]) //VerifyPresentation
  
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    iPrint(container)
    if let x = try? container.decode([String].self) {
      self = .string(x)
      return
    }
    if let x = try? container.decode(CredentialPayload.self) {
      self = .credential(x)
      return
    }
    if let x = try? container.decode([CredentialPayload].self) {
      self = .credentialArray(x)
      return
    }
    throw DecodingError.typeMismatch(VerifiableCredentialType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for vc Value"))
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .string(let value):
      try container.encode(value)
    case .credential(let value):
      try container.encode(value)
    case .credentialArray(let value):
      try container.encode(value)
    }
  }
  //
  var credentialValue: Any {
    switch self {
    case .string(let s):
      return s
    case .credential(let payload):
      return payload
    case .credentialArray(let payloads):
      return payloads
    }
  }
}

public struct JwtPresentationPayload: Codable {
  var vp: VerifiablePresentationObject? //Extensible Object
  var iss: String?
  var aud: [String]?
  var nbf: Date?
  var exp: Date?
  var jti: String?
  var nonce: String?
  var iat: Date?
}

public struct JwtCredentialPayload: Codable {
  var vc: VerifiableCredentialObject? //Extensible Object
  var iss: String?
  var aud: [String]?
  var nbf: Date?
  var exp: Date?
  var jti: String?
  var nonce: String?
  var iat: Date?
  var sub: String?
}

public struct PresentationPayload: Codable {
  var context: [String]
  var type: [String]
  var id: String?
  var verifiableCredential: VerifiableCredentialType // [credentialPayload] or credentialPayload
  var holder: String
  var verifier: [String]?
  var issuanceDate: String?
  var expirationDate: String?
  var proof: [String:String]
  
  public init(context: [String] = [], type: [String] = [], verifiableCredential: VerifiableCredentialType = VerifiableCredentialType.string([]), holder: String = "", proof: [String:String] = [:], id: String? = nil,
              verifier: [String]? = nil, issuanceDate: String? = nil, expirationDate: String? = nil) {
    self.context = context
    self.type = type
    self.verifiableCredential = verifiableCredential
    self.holder = holder
    self.proof = proof
    self.id = id
    self.issuanceDate = issuanceDate
    self.expirationDate = expirationDate
    self.verifier = verifier
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    context = (try? values.decode([String].self, forKey: .context)) ?? []
    type = (try? values.decode([String].self, forKey: .type)) ?? []
    id = (try? values.decode(String.self, forKey: .id)) ?? nil
    verifiableCredential = (try? values.decode(VerifiableCredentialType.self, forKey: .verifiableCredential)) ?? VerifiableCredentialType.string([])
    holder = (try? values.decode(String.self, forKey: .holder)) ?? ""
    verifier = (try? values.decode([String].self, forKey: .verifier)) ?? []
    issuanceDate = (try? values.decode(String.self, forKey: .issuanceDate)) ?? nil
    expirationDate = (try? values.decode(String.self, forKey: .expirationDate)) ?? nil
    proof = (try? values.decode([String:String].self, forKey: .proof)) ?? [:]
    
  }
  
  public func encode(from encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.context, forKey: .context)
    try container.encode(self.type, forKey: .type)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.verifiableCredential, forKey: .verifiableCredential)
    try container.encode(self.holder, forKey: .holder)
    try container.encode(self.verifier, forKey: .verifier)
    try container.encode(self.issuanceDate, forKey: .issuanceDate)
    try container.encode(self.expirationDate, forKey: .expirationDate)
    try container.encode(self.proof, forKey: .proof)
  }
}

public struct Issuer {
  var did: String
  var signer: JWTSigner
  var alg: String?
}

public struct CredentialOptions {
  var domain: String?
  var challenge: String?
  var audience: String?
  
  public init(audience: String? = nil) {
    self.audience = audience
  }
}

public struct PresentationOptions {
  var domain: String?
  var challenge: String?
  var audience: String?
  var vcValidateFlag: Bool
  
  public init(audience: String? = nil, vcValidateFlag: Bool = false) {
    self.audience = audience
    self.vcValidateFlag = vcValidateFlag
  }
}


public func transformPresentationInput(input: PresentationPayload, removeOriginalFields: Bool = true) -> JwtPresentationPayload {
  //  guard let vp = try? NSKeyedArchiver.archivedData(withRootObject: input, requiringSecureCoding: true) else { return JwtPresentationPayload()}
  //iPrint(input)
  guard let aud = input.verifier else { return JwtPresentationPayload()}
  let formatter = ISO8601DateFormatter.init()
  
  if type(of: input.verifiableCredential) is String.Type {
    iPrint(input)
  }
  
  guard let vcData = try? input.verifiableCredential.toJsonData(),
        let vcType = try? JSONDecoder().decode(VerifiableCredentialType.self, from: vcData),
        let vc = vcType.credentialValue as? [String]
  else { return JwtPresentationPayload() }
  //test
  iPrint(vc)
  
  var payload: JwtPresentationPayload = JwtPresentationPayload(vp: VerifiablePresentationObject(context: input.context, type: input.type, verifiableCredential: vc), iss: input.holder, aud: aud, nbf: nil, exp: nil, jti: nil, nonce: nil)
  
  iPrint(payload)
  if input.expirationDate != nil, let expDate = input.expirationDate {
    let exp = floor(formatter.date(from: expDate)!.timeIntervalSinceNow / 1000)
    iPrint(expDate)
    payload.exp = formatter.date(from: Date(timeIntervalSinceNow: exp).ISO8601Format())
  }
  
  if input.issuanceDate != nil, let issDate = input.issuanceDate {
    //let nbf = floor(Double(issDate.timeIntervalSinceNow) / 1000)
    iPrint(issDate)
    let iss = floor(formatter.date(from: issDate)!.timeIntervalSinceNow / 1000)
    payload.nbf = formatter.date(from: Date(timeIntervalSinceNow: iss).ISO8601Format())
  }
  
  if input.id != nil, let id = input.id {
    payload.jti = id
  }
  
  iPrint(payload)
  return payload
}

public func transformCredentialInput(input: CredentialPayload) -> JwtCredentialPayload {
  var jwtPayload: JwtCredentialPayload = JwtCredentialPayload()
  
  iPrint(input)
  let formatter = ISO8601DateFormatter()
  
  let credentialSubject = try! JSONDecoder().decode(VerifiableCredentialObject.self, from: try! input.toJsonData())
//  jwtPayload.vc?.credentialSubject = input.credentialSubject
//  jwtPayload.vc?.context = input.context
//  jwtPayload.vc?.type = input.type
  
  jwtPayload.vc = credentialSubject
  
  jwtPayload.sub = input.credentialSubject["id"] ?? nil
  
  jwtPayload.jti = input.id ?? nil
  
  // Date transform
  jwtPayload.nbf = formatter.date(from: input.issuanceDate ?? "")//input.issuanceDate
  jwtPayload.exp = formatter.date(from: input.expirationDate ?? "")
  
  jwtPayload.iss = input.issuer.first?.value ?? nil
  
  return jwtPayload
}
