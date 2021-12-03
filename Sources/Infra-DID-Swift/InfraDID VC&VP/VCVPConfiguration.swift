//
//  File.swift
//
//
//  Created by SatGatLee on 2021/12/01.
//

import Foundation
//types, Converters, validators Integration



public struct CredentialStatus {
  var id: String
  var type: String
}


public enum EvidenceType {
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
  
  func encode(from encoder: Encoder) throws {
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

public struct CredentialPayload { // organic struct add payload after verify Credential
  var context: [String]
  var id: String?
  var type: [String]
  var issuer: [String:String]
  var issuanceDate: DateType
  var expirationDate: DateType?
  var credentialSubject: SubjectType
  var credentialStatus: CredentialStatus
  var evidence: EvidenceType?
  var termsOfUse: EvidenceType?
  var proof = [String:String]()
}

public struct VerifiedCredential { //검증끝난 전체 데이터 구조
  var verifiedJwt: JwtVerified
  var verifiableCredential: CredentialPayload
}

public struct VerifiedPresentation {
  var verifiedJwt: JwtVerified
  var verifiableCredential: PresentationPayload
}
public struct VerifiablePresentationObject: Codable {
  var context: [String]
  var type: [String]
  var verifiableCredential: [String]
  
}

//
//public enum VerifiableCredentialType {
//  case string(String)
//  case credential()
//}

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

public struct PresentationPayload: Codable {
  var context: [String]
  var type: [String]
  var id: String?
  var verifiableCredential: [String]
  var holder: String
  var verifier: String?
  var issuanceDate: String?
  var expirationDate: String?
}


public struct Issuer {
  var did: String
  var signer: JWTSigner
  var alg: String?
}

public struct CreatePresentationOptions {
  var domain: String?
  var challenge: String?
  
  public init() {}
}

public struct VerifyPresentationOptions {
  var domain: String?
  var challenge: String?
  
  public init() {}
}


public func transformPresentationInput(input: PresentationPayload, removeOriginalFields: Bool = true) -> JwtPresentationPayload {
//  guard let vp = try? NSKeyedArchiver.archivedData(withRootObject: input, requiringSecureCoding: true) else { return JwtPresentationPayload()}
  //iPrint(input)
  guard let aud = input.verifier else { return JwtPresentationPayload()}
  let formatter = ISO8601DateFormatter.init()
  var payload: JwtPresentationPayload = JwtPresentationPayload(vp: VerifiablePresentationObject(context: input.context, type: input.type, verifiableCredential: input.verifiableCredential), iss: input.holder, aud: [aud], nbf: nil, exp: nil, jti: nil, nonce: nil)
  
  //formatter.date(from: <#T##String#>)
  //iPrint(input.expirationDate)
  iPrint(payload)
  if input.expirationDate != nil, let expDate = input.expirationDate {

    //let exp = floor(Double(expDate.timeIntervalSinceNow) / 1000)
    payload.exp = formatter.date(from: expDate)
  }
  
  if input.issuanceDate != nil, let issDate = input.issuanceDate {
    //let nbf = floor(Double(issDate.timeIntervalSinceNow) / 1000)
    payload.nbf = formatter.date(from: issDate)
  }
  if input.id != nil, let id = input.id {
    payload.jti = id
  }
  
  iPrint(payload)
  return payload
}
