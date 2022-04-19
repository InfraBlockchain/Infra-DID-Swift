//
//  File.swift
//
//
//  Created by SatGatLee on 2021/12/01.
//

import Foundation

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

/** Enum SubjectValue
 - CredentialSubject Value For UnionType
 
 - Case with:
 
    - String
    - Int
    - Double
    - Boolean
    - Dictionary<String: SubjectValue>
    - Array
 
 */
public enum SubjectValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: SubjectValue])
    case array([SubjectValue])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([String: SubjectValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([SubjectValue].self) {
            self = .array(value)
        } else {
            throw DecodingError.typeMismatch(SubjectValue.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a JSON"))
        }
    }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .string(let value):
      try container.encode(value)
    case .int(let value):
      try container.encode(value)
    case .double(let value):
      try container.encode(value)
    case .object(let value):
      try container.encode(value)
    case .array(let value):
      try container.encode(value)
    case .bool(let value):
      try container.encode(value)
    }
  }
  
  ///Get Property Value
  public var credentialValue: Any {
    switch self {
    case .object(let payoad):
      return payoad
    case .array(let payload):
      return payload
    case .string(let str):
      return str
    case .int(let int):
      return int
    case .double(let double):
      return double
    case .bool(let bool):
      return bool
    }
  }
}

public struct VerifiableCredentialObject: Codable {
  public var context: [String]
  public var type: [String]
  public var credentialSubject: SubjectValue
  
  public enum CodingKeys: String, CodingKey {
    case context = "@context"
    case type, credentialSubject
  }
  
  public init(from decoder: Decoder) throws {
    
    let values = try decoder.container(keyedBy: CodingKeys.self)
    context = (try? values.decode([String].self, forKey: .context)) ?? []
    type = (try? values.decode([String].self, forKey: .type)) ?? []
    credentialSubject = (try? values.decode(SubjectValue.self, forKey: .credentialSubject)) ?? SubjectValue.array([])
    
  }
  
  public func encode(from encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.context, forKey: .context)
    try container.encode(self.type, forKey: .type)
    try container.encode(self.credentialSubject, forKey: .credentialSubject)
  }
  
}


/**
 
 Represents the result of a Credential verification. It includes the properties produced by did-jwt and a W3C compliant representation of the Credential that was just verified.
 
 This is usually the result of a verification method and not meant to be created by generic code.
 
 - **Property with**
 
    - verifiedJwt
    - verifiableCredential
 
 */
public struct VerifiedCredential: Codable {
  public var verifiedJwt: JwtVerified
  public var verifiableCredential: CredentialPayload
  
  public init(verifiedJwt: JwtVerified = JwtVerified(), verifiableCredential: CredentialPayload = CredentialPayload()) {
    self.verifiedJwt = verifiedJwt
    self.verifiableCredential = verifiableCredential
  }
}

/**
 
 Represents the result of a Presentation verification. It includes the properties produced by did-jwt and a W3C compliant representation of the Presentation that was just verified.
 This is usually the result of a verification method and not meant to be created by generic code.
 
 - **Property with**
 
    - verifiedJwt
    - verifiablePresentation
    - verifiableCredentials
 
 */
public struct VerifiedPresentation: Codable {
  public var verifiedJwt: JwtVerified
  public var verifiablePresentation: PresentationPayload
  public var verifiableCredentials: [VerifiedCredential] // Verified Result vc in vp
  
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
  public var context: [String]
  public var type: [String]
  public var verifiableCredential: [String]
  
  public enum CodingKeys: String, CodingKey {
    case context = "@context"
    case type, verifiableCredential
  }
}

/** Enum VerifiableCredentialType
 
 VerifiableCredentials Union Type
 
 - Case with:
 
    - String
    - CredentialPayload
    - Array of CredentialPayload
 
 */
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
  
  public var credentialValue: Any {
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

/**
 
 A JWT payload representation of a Presentation
 
 See also:
 https://www.w3.org/TR/vc-data-model/#jwt-encoding
 
 - **Property with**
 
    - vp
    - iss
    - aud
    - nbf
    - exp
    - jti
    - nonce
    - iat
 
 */
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

/**
 
 A JWT payload representation of a Credential
 
 See also:
 https://www.w3.org/TR/vc-data-model/#jwt-encoding
 
 - **Property with**
 
    - vc
    - iss
    - aud
    - nbf
    - exp
    - jti
    - nonce
    - iat
    - sub
 
 */
public struct JwtCredentialPayload: Codable {
  var vc: VerifiableCredentialObject?
  var iss: String?
  var aud: [String]?
  var nbf: Date?
  var exp: Date?
  var jti: String?
  var nonce: String?
  var iat: Date?
  var sub: String?
}

/**
 
 used as input when creating Verifiable Presentations
 
 - **Property with**
 
    - context
    - type
    - id
    - verifiableCredential
    - holder
    - verifier
    - issuanceDate
    - expirationDate
    - proof
 
 */
public struct PresentationPayload: Codable {
 public var context: [String]
 public var type: [String]
 public var id: String?
 public var verifiableCredential: VerifiableCredentialType
 public var holder: String
 public var verifier: [String]?
 public var issuanceDate: String?
 public var expirationDate: String?
 public var proof: [String:String]
  
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


/**
 - Used as input when creating Verifiable Credentials
 
 - **Property with**
 
    - context
    - id
    - type
    - issuer
    - issuanceDate
    - expirationDate
    - credentialSubject
    - evidence
    - termOfUse
    - proof
 
 */
public struct CredentialPayload: Codable {
  public var context: [String]
  public var id: String?
  public var type: [String]
  public var issuer: [String:String]
  public var issuanceDate: String?
  public var expirationDate: String?
  public var credentialSubject: SubjectValue
  public var credentialStatus: CredentialStatus
  public var evidence: EvidenceType?
  public var termsOfUse: EvidenceType?
  public var proof = [String:String]()
  
  public enum CodingKeys: String, CodingKey {
    case context = "@context"
    case id, type, issuer, issuanceDate, expirationDate, credentialSubject, credentialStatus, evidence, termsOfUse, proof
  }
  
  public init(context: [String] = [], id: String? = nil, type: [String] = [] ,
              issuer: [String:String] = [:], issuanceDate: String? = nil, expirationDate: String? = nil,
              credentialSubject: SubjectValue = SubjectValue.object([:]), credentialStatus: CredentialStatus = CredentialStatus(),
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
    credentialSubject = (try? values.decode(SubjectValue.self, forKey: .credentialSubject)) ?? SubjectValue.object([:])
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

/**
 
 Represents the Verification Options that can be passed to the verifyCredential method.
 These options are forwarded to the lower level verification code
 
 - **Property with**
 
    - domain
    - challenge
    - audience
 
 */
public struct CredentialOptions {
  var domain: String?
  var challenge: String?
  var audience: String?
  
  public init(audience: String? = nil) {
    self.audience = audience
  }
}

/**
 
 Represents the Verification Options that can be passed to the verifyPresentation And CreateVPJWT method.
 The verification will fail if given options are NOT satisfied.
 
 - **Property with**
 
    - domain
    - challenge
    - audience
    - vcValidateFlag
 
 */
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


/**
 Method Transforms a W3C Presentation payload into a JWT compatible encoding. The method accepts app specific fields and in case of collision, existing JWT properties will take precedence. Also, nbf, exp and jti properties can be explicitly set to undefined and they will be kept intact.
 
 - Parameter PresentationPayload
 
 - Throws: None
 
 - Returns: JwtPresentationPayload
 
 */
public func transformPresentationInput(input: PresentationPayload, removeOriginalFields: Bool = true) -> JwtPresentationPayload {
  guard let aud = input.verifier else { return JwtPresentationPayload()}
  let formatter = ISO8601DateFormatter()
  
  guard let vcData = try? input.verifiableCredential.toJsonData(),
        let vcType = try? JSONDecoder().decode(VerifiableCredentialType.self, from: vcData),
        let vc = vcType.credentialValue as? [String]
  else { return JwtPresentationPayload() }
  
  var payload: JwtPresentationPayload = JwtPresentationPayload(vp: VerifiablePresentationObject(context: input.context, type: input.type, verifiableCredential: vc), iss: input.holder, aud: aud, nbf: nil, exp: nil, jti: nil, nonce: nil)
  
  if input.expirationDate != nil, let expDate = input.expirationDate {
    let exp = floor(formatter.date(from: expDate)!.timeIntervalSinceNow / 1000)
    iPrint(expDate)
    
    
    payload.exp = formatter.date(from: formatter.string(from: Date(timeIntervalSinceNow: exp)))//formatter.date(from: Date(timeIntervalSinceNow: exp))
  }
  
  if input.issuanceDate != nil, let issDate = input.issuanceDate {
    let iss = floor(formatter.date(from: issDate)!.timeIntervalSinceNow / 1000)
    payload.nbf = formatter.date(from: formatter.string(from: Date(timeIntervalSinceNow: iss)))//formatter.date(from: Date(timeIntervalSinceNow: iss).ISO8601Format())
  }
  
  if input.id != nil, let id = input.id {
    payload.jti = id
  }
  
  return payload
}


/**
 Method Transforms a W3C Credential payload into a JWT compatible encoding. The method accepts app specific fields and in case of collision, existing JWT properties will take precedence. Also, nbf, exp and jti properties can be explicitly set to undefined and they will be kept intact.
 
 - Parameter CredentialPayload
 
 - Throws: None
 
 - Returns: JwtCredentialPayload
 
 */
public func transformCredentialInput(input: CredentialPayload) -> JwtCredentialPayload {
  var jwtPayload: JwtCredentialPayload = JwtCredentialPayload()
  
  let formatter = ISO8601DateFormatter()
  
  guard let inputData = try? input.toJsonData(),
          let credentialSubject = try? JSONDecoder().decode(VerifiableCredentialObject.self, from: inputData),
        let credentialSubjectValue = credentialSubject.credentialSubject.credentialValue as? [String:Any]
  else { return JwtCredentialPayload() }
    
  jwtPayload.vc = credentialSubject
  
  jwtPayload.sub = credentialSubjectValue["id"] as? String ?? ""
  
  jwtPayload.jti = input.id ?? nil
  
  jwtPayload.nbf = formatter.date(from: input.issuanceDate ?? "")
  jwtPayload.exp = formatter.date(from: input.expirationDate ?? "")
  
  jwtPayload.iss = input.issuer.first?.value ?? nil
  
  return jwtPayload
}
