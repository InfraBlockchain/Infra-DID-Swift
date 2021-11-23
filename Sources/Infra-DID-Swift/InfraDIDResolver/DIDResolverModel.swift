//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/11/18.
//

import Foundation
import PromiseKit

public struct DIDResolutionResultSet: Decodable {
  var didResolutionResult: DIDResolutionResult
  
  public enum CodingKeys: CodingKey {
    case didResolutionResult
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    didResolutionResult = (try? values.decode(DIDResolutionResult.self, forKey: .didResolutionResult)) ?? DIDResolutionResult()
  }
}

public struct DIDResolutionResult: Decodable {
  
  var didResolutionMetadata: DIDResolutionMetadata
  var didDocument: DIDDocument?
  var didDocumentMetadata: DIDDocumentMetaData
  
  public enum CodingKeys: CodingKey {
    case didResolutionMetadata
    case didDocument
    case didDocumentMetadata
  }
  
  //  public init(from decoder: Decoder) throws {
  //    let values = try decoder.container(keyedBy: CodingKeys.self)
  //    didResolutionMetadata = (try? values.decode(DIDResolutionMetadata.self, forKey: .didResolutionMetadata)) ?? DIDResolutionMetadata()
  //    //didDocument = (try? values.decode(DIDDocument?.self, forKey: .didDocument)) ?? nil
  //    //didDocumentMetadata = (try? values.decode(DIDDocumentMetaData.self, forKey: .didDocumentMetadata)) ?? DIDDocumentMetaData()
  //  }
  
  public init(didResolutionMetadata: DIDResolutionMetadata
              = DIDResolutionMetadata(),
              didDocument: DIDDocument? = nil,
              didDocumentMetaData: DIDDocumentMetaData = DIDDocumentMetaData()) {
    self.didResolutionMetadata = didResolutionMetadata
    self.didDocument = didDocument
    self.didDocumentMetadata = didDocumentMetaData
  }
  
}


public struct DIDResolutionOptions: Decodable {
  var accept: String?
  
  public enum CodingKeys: CodingKey {
    case accept
  }
  
  //  public init(from decoder: Decoder) throws {
  //    let values = try decoder.container(keyedBy: CodingKeys.self)
  //    accept = (try? values.decode(String?.self, forKey: .accept))
  //  }
  
  public init(accept: String? = nil) {
    self.accept = accept
  }
}

public enum ErrorType: String, Codable {
  case invalidDid = "invalidDid"
  case notFound = "notFound"
  case representationNotSupported = "representationNotSupported"
  case unsupportedDidMethod = "unsupportedDidMethod"
  case unKnownNetwork = "unKnownNetwork"
}

public struct DIDResolutionMetadata: Codable {
  var contentType: String?
  var errorDescription: ErrorType?
  var message: String?
  
  public enum CodingKeys: CodingKey {
    case contentType
    case errorDescription
    case message
  }
  
  public init(contentType: String? = nil, errorDescription: ErrorType? = nil, message: String? = nil) {
    self.contentType = contentType
    self.errorDescription = errorDescription
    self.message = message
  }
}

//extension DIDResolutionMetadata: Decodable {
//  public init(from decoder: Decoder) throws {
//    let values = try decoder.container(keyedBy: CodingKeys.self)
//    contentType = (try? values.decodeIfPresent(String?.self, forKey: .contentType)) ?? nil
//    errorDescription = (try? values.decodeIfPresent(ErrorType?.self, forKey: .errorDescription)) ?? nil
//    message = (try? values.decodeIfPresent(String?.self, forKey: .message)) ?? nil
//  }
//}

public struct DIDDocumentMetaData: Codable {
  var created: String?
  var updated: String?
  var deactivated: Bool?
  var versionId: String?
  var nextUpdate: String?
  var nextVersionId: String?
  var equivalentId: String?
  var canonicalId: String?
  
  
  public enum CodingKeys: CodingKey {
    case created, updated, deactivated, versionId, nextUpdate, nextVersionId, equivalentId, canonicalId
  }
  
  public init(created: String? = nil, updated: String? = nil, deactivated: Bool? = false,
              versionId: String? = nil, nextUpdate: String? = nil, nextVersionId: String? = nil,
              equivalentId: String? = nil, canonicalId: String? = nil) {
    self.created = created
    self.updated = updated
    self.deactivated = deactivated
    self.versionId = versionId
    self.nextUpdate = nextUpdate
    self.nextVersionId = nextVersionId
    self.equivalentId = equivalentId
    self.canonicalId = canonicalId
    
  }
  
  //      public init(from decoder: Decoder) throws {
  //        let values = try decoder.container(keyedBy: CodingKeys.self)
  //        created = (try? values.decode(String.self, forKey: .created)) ?? nil
  //        updated = (try? values.decode(String.self, forKey: .updated)) ?? nil
  //        deactivated = (try? values.decode(Bool.self, forKey: .deactivated)) ?? nil
  //        versionId = (try? values.decode(String.self, forKey: .versionId)) ?? nil
  //        nextUpdate = (try? values.decode(String.self, forKey: .nextUpdate)) ?? nil
  //        nextVersionId = (try? values.decode(String.self, forKey: .nextVersionId)) ?? nil
  //        equivalentId = (try? values.decode(String.self, forKey: .equivalentId)) ?? nil
  //        canonicalId = (try? values.decode(String.self, forKey: .canonicalId)) ?? nil
  //      }
}

//
public enum KeyCapabilitySectionType: String {
  case authentication = "authentication"
  case assertionMethod = "assertionMethod"
  case keyAgreement = "keyAgreement"
  case capabilityInvocation = "capabilityInvocation"
  case capabilityDelegation = "capabilityDelegation"
}

public struct KeyCapabilitySection {
  var keyCapabilitySection: KeyCapabilitySectionType
}

public enum contextType: Codable {
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
    throw DecodingError.typeMismatch(contextType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for MyValue"))
  }
}

public enum controllerType: Codable {
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
    throw DecodingError.typeMismatch(controllerType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for MyValue"))
  }
}

public struct DIDDocument {
  var context: contextType? //string or [string]
  var id: String
  var alsoKnownAs: [String]?
  var controller: controllerType?
  var verificationMethod: [VerificationMethod]?
  var service: [ServiceEndpoint]?
  var publicKey: [VerificationMethod]?
  var authentication: [String]
  
  enum CodingKeys: String, CodingKey {
    case context = "@context"
    case id, alsoKnownAs, controller, verificationMethod, service, publicKey, authentication
  }
  
  public init(context: contextType? = nil, id: String = "", alsoKnownAs: [String]? = nil,
              controller: controllerType? = nil,
              verificationMethod: [VerificationMethod]? = [], service: [ServiceEndpoint]? = [],
              publicKey: [VerificationMethod]? = [], authentication: [String] = []) {
    self.context = context
    self.id = id
    self.alsoKnownAs = alsoKnownAs
    self.controller = controller
    self.verificationMethod = verificationMethod
    self.service = service
    self.publicKey = publicKey
    self.authentication = authentication
  }
}
extension DIDDocument: Decodable {
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    context = (try? values.decode(contextType?.self, forKey: .context)) ?? nil
    id = (try? values.decode(String.self, forKey: .id)) ?? ""
    alsoKnownAs = (try? values.decode([String]?.self, forKey: .alsoKnownAs)) ?? nil
    controller = (try? values.decode(controllerType?.self, forKey: .controller)) ?? nil
    verificationMethod = (try? values.decode([VerificationMethod]?.self, forKey: .verificationMethod)) ?? nil
    service = (try? values.decode([ServiceEndpoint]?.self, forKey: .service)) ?? nil
    publicKey = (try? values.decode([VerificationMethod]?.self, forKey: .publicKey)) ?? nil
    authentication = (try? values.decode([String].self, forKey: .authentication)) ?? []
  }
}

public struct ServiceEndpoint: Codable {
  var id: String
  var type: String
  var serviceEndpoint: String
  var description: String?
  
  public enum CondingKeys: CodingKey {
    case id, type, serviceEndpoint, description
  }
  
  //      public init(from decoder: Decoder) throws {
  //        let values = try decoder.container(keyedBy: CodingKeys.self)
  //        id = (try? values.decode(String.self, forKey: .id)) ?? ""
  //        type = (try? values.decode(String.self, forKey: .type)) ?? ""
  //        serviceEndpoint = (try? values.decode(String.self, forKey: .serviceEndpoint)) ?? ""
  //        description = (try? values.decode(String.self, forKey: .description)) ?? nil
  //      }
  
  init(id: String = "", type: String = "", serviceEndpoint: String = "", description: String? = nil) {
    self.id = id
    self.type = type
    self.serviceEndpoint = serviceEndpoint
    self.description = description
  }
}
//
public struct JsonWebKey: Codable {
  var alg: String?
  var crv: String?
  var e: String?
  var ext: String?
  var key_ops: [String?]
  var kid: String?
  var kty: String
  var n: String?
  var use: String?
  var x: String?
  var y: String?
  
  public enum CodingKeys: CodingKey {
    case alg, crv, e, ext, key_ops, kid, kty, n, use, x, y
  }
  
  //      public init(from decoder: Decoder) throws {
  //        let values = try decoder.container(keyedBy: CodingKeys.self)
  //        alg = (try? values.decode(String.self, forKey: .alg)) ?? nil
  //        crv = (try? values.decode(String.self, forKey: .crv)) ?? nil
  //        e = (try? values.decode(String.self, forKey: .e)) ?? nil
  //        ext = (try? values.decode(String.self, forKey: .ext)) ?? nil
  //        key_ops = (try? values.decode([String?].self, forKey: .key_ops)) ?? nil
  //        kid = (try? values.decode(String.self, forKey: .kid)) ?? nil
  //        kty = (try? values.decode(String.self, forKey: .kty)) ?? ""
  //        n = (try? values.decode(String.self, forKey: .n)) ?? nil
  //        use = (try? values.decode(String.self, forKey: .use)) ?? nil
  //        x = (try? values.decode(String.self, forKey: .x)) ?? nil
  //        y = (try? values.decode(String.self, forKey: .y)) ?? nil
  //      }
  
  public init(alg: String? = nil, crv: String? = nil, e: String? = nil,
              ext: String? = nil, key_ops: [String?] = [], kid: String? = nil,
              kty: String = "", n: String? = nil, use: String? = nil, x: String? = nil, y: String? = nil) {
    self.alg = alg
    self.crv = crv
    self.e = e
    self.ext = ext
    self.key_ops = key_ops
    self.kid = kid
    self.kty = kty
    self.n = n
    self.use = use
    self.x = x
    self.y = y
  }
}


public struct VerificationMethod: Codable {
  var id: String
  var type: String
  var controller: String
  var publicKeyBase58: String?
  var publicKeyBase64: String?
  var publicKeyJwk: JsonWebKey?
  var publicKeyHex: String?
  var publicKeyMultibase: String?
  var blockchainAccountId: String?
  var ethereumAddress: String?
  
  public enum CodingKeys: CodingKey {
    case id, type, controller, publicKeyBase58, publicKeyBase64, publicKeyJwk, publicKeyHex, publicKeyMultibase,
         blockchainAccountId, ethereumAddress
  }
  
  public init(id: String = "", type: String = "", controller: String = "", publicKeyBase58: String? = nil,
              publicKeyBase64: String? = nil, publicKeyJwk: JsonWebKey? = nil, publicKeyHex: String? = nil,
              publicKeyMultibase: String? = nil, blockchainAccountId: String? = nil, ethereumAddress: String?) {
    self.id = id
    self.type = type
    self.controller = controller
    self.publicKeyBase58 = publicKeyBase58
    self.publicKeyBase64 = publicKeyBase64
    self.publicKeyJwk = publicKeyJwk
    self.publicKeyHex = publicKeyHex
    self.publicKeyMultibase = publicKeyMultibase
    self.blockchainAccountId = blockchainAccountId
    self.ethereumAddress = ethereumAddress
  }
}
//
public struct Params: Codable {
  var params: [String:String]
  
  public enum CondingKeys: CodingKey {
    case params
  }
  
  init(object: [String: String]) {
    self.params = object
  }
}

public struct ParsedDID: Codable {
  var did: String
  var didUrl: String
  var method: String
  var id: String
  var path: String?
  var fragment: String?
  var query: String?
  var params: Params?
  
  
  public enum CodingKeys: CodingKey {
    case did, didUrl, method, id, path, fragment, query, params
  }
  public init(did: String = "", didUrl: String = "", method: String = "", id: String = "",
              path: String? = nil, fragment: String? = nil, query: String? = nil, params: Params? = nil) {
    self.did = did
    self.didUrl = didUrl
    self.method = method
    self.id = id
    self.path = path
    self.fragment = fragment
    self.query = query
    self.params = params
  }
}

//
public func DIDResolve(did: String, parsed: ParsedDID, resolver: Resolver, options: DIDResolutionOptions) -> Promise<DIDResolutionResult> {
  return Promise<DIDResolutionResult>.value(DIDResolutionResult())
}
public var didResolver = WrappedResolve
public typealias DIDResolverType = (String, ParsedDID, Resolver, DIDResolutionOptions) -> Promise<DIDResolutionResult>
//

//
public func WrappedResolve() -> Promise<DIDResolutionResult>
{ return Promise<DIDResolutionResult>.value(DIDResolutionResult()) }
public var wrappedResolver: () -> Promise<DIDResolutionResult> = WrappedResolve
public typealias wrappedResolverType = () -> Promise<DIDResolutionResult>
//


//
public func DIDCache(parsed: ParsedDID, resolve: @escaping wrappedResolverType) -> Promise<DIDResolutionResult>
{ return Promise<DIDResolutionResult>.value(DIDResolutionResult()) }
public var didCache = DIDCache
public typealias DidCacheType = (ParsedDID, @escaping wrappedResolverType) -> Promise<DIDResolutionResult>
//

//
public func LegacyDIDResolve(did: String, parsed: ParsedDID, resolver: Resolver) -> Promise<DIDDocument>
{ return Promise<DIDDocument>.value(DIDDocument()) }
public var legacyDIDResolver = LegacyDIDResolve
public typealias LegacyDIDResolverType = (String, ParsedDID, Resolver) -> Promise<DIDDocument>
//


public enum ResolverOptionsType {
  case bool(Bool)
  case cache(DidCacheType)
}

public struct ResolverOptions {
  var cache: ResolverOptionsType?
  var legacyResolver: [String:LegacyDIDResolverType]?
  
  init(cache: ResolverOptionsType? = nil, legacyResolver: [String:LegacyDIDResolverType]? = nil) {
    self.cache = cache
    self.legacyResolver = legacyResolver
  }
}

public struct ResolverRegistry {
  var methodName: [String: DIDResolverType]
  
  init(methodName: [String: DIDResolverType] = [:]) {
    self.methodName = methodName
  }
}


//global Constant
public var currentParsedDID: ParsedDID? = nil
public var currentParsedDIDDocument: DIDResolutionResult? = nil



public func inMemoryCache() -> DidCacheType {
  var cache: [String:DIDResolutionResult] = [:]
  //var caches : DidCacheType
  //guard let parsedDID = currentParsedDID else { return WrappedResolve() }
  let caches : DidCacheType = { did, wrapped in
    if did.params != nil && did.params?.params["no-cache"] == "true" {
      return wrapped()
    }
    
    let cached = cache[did.didUrl]
    if cached != nil { return Promise<DIDResolutionResult>.value(cached!) }
    let result = wrapped()
    
    if result.value?.didResolutionMetadata.errorDescription != .notFound {
      cache[did.didUrl] = result.value!
    }
    return result
  }
  return caches
}

let pctEncoded = "(?:%[0-9a-fA-F]{2})"
let idChar = "(?:[a-zA-Z0-9._-]|\(pctEncoded))"
let method = "([a-z0-9]+)"
let methodId = "(?:\(idChar)*:)*(\(idChar)+)"
let paramChar = "[a-zA-Z0-9_.:%-]"
let param = ";\(paramChar)+=\(paramChar)*"
let params = "((\(param))*)"
let path = "(/[^#?]*)?"
let query = "([?][^#]*)?"
let fragment = "(#.*)?"

//0. did 1. methodName 2.id 3.params 4.param 5.path 6.query 7.fragment
public func parse(didUrl: String) -> ParsedDID? {
  //base case
  guard didUrl != "" else { return nil }
  
  let sections = didUrl.matchingStrings(regex: "^did:\(method):\(methodId)\(params)\(path)\(query)\(fragment)$")[0]
  
  if sections.count != 0 {
    let paramSplits = sections[3].split(separator: ";")
    var param: [String:String] = [:]
    let _ = paramSplits.reduce(into: [String:String]()) { (_, params) in
      let p = params.split(separator: "=")
      param[String(p[0])] = String(p[1])
    }
    
    let parts: ParsedDID = ParsedDID(did: "did:\(sections[1]):\(sections[2])", didUrl: didUrl, method: sections[1], id: sections[2], path: sections[5] == "" ? nil : sections[5], fragment: sections[7] == "" ? nil : sections[7], query: sections[6] == "" ? nil : sections[6], params: Params(object: param))
    
    currentParsedDID = parts
    return parts
  }
  return nil
}

public func wrapLegacyResolver(resolve: LegacyDIDResolverType) -> DIDResolverType {
  //var didResolver: DIDResolverType = DIDResolverType()
  
  let didResolver: DIDResolverType = {  _, _, _, _ in
    var doc = Promise<DIDDocument>.value(DIDDocument())
    do {
      let legacy: LegacyDIDResolverType = { did, parsedDID, resolver in
        doc = LegacyDIDResolve(did: did, parsed: parsedDID, resolver: resolver)
        return doc
      }
      guard let document = doc.value else { return Promise<DIDResolutionResult>.value(DIDResolutionResult())}
      return Promise<DIDResolutionResult>.value(DIDResolutionResult(
        didResolutionMetadata: DIDResolutionMetadata(contentType: "application/did+ld+json", errorDescription: nil, message: nil), didDocument: document, didDocumentMetaData: DIDDocumentMetaData()))
    }
    catch(let err) {
        return Promise<DIDResolutionResult>.value(DIDResolutionResult(didResolutionMetadata: DIDResolutionMetadata(contentType: nil,
                                  errorDescription: .notFound,
                                  message: err.localizedDescription),
                                  didDocument: nil,
                                  didDocumentMetaData: DIDDocumentMetaData()))
    }
  }
  return didResolver
}



extension String{
  func matchingStrings(regex: String) -> [[String]] {
    guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
    let nsString = self as NSString
    let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
    return results.map { result in
      (0..<result.numberOfRanges).map {
        result.range(at: $0).location != NSNotFound
        ? nsString.substring(with: result.range(at: $0))
        : ""
      }
    }
  }
}
