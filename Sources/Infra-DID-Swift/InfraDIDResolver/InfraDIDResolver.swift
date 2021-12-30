//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/11/23.
//

import Foundation
import PromiseKit
import EosioSwift
import secp256k1

public enum APIError: Error {
  case emptyError
  case parsingError
  case resultError
}

public enum verificationMethodTypes: String {
  case EcdsaSecp256k1VerificationKey2019 = "EcdsaSecp256k1VerificationKey2019"
  case EcdsaSecp256k1RecoveryMethod2020 = "EcdsaSecp256k1RecoveryMethod2020"
  case Ed25519VerificationKey2018 = "Ed25519VerificationKey2018"
  case RSAVerificationKey2018 = "RSAVerificationKey2018"
  case X25519KeyAgreementKey2019 = "X25519KeyAgreementKey2019"
}

public struct ResolvedDIDDocument {
  public var didDocument: DIDDocument?
  public var deactivated: Bool
  
  public init(didDocument: DIDDocument? = nil, deactivated: Bool = false) {
    self.didDocument = didDocument
    self.deactivated = deactivated
  }
}

public protocol InfraDIDResolvable {
  func resolve(did: String, parsed: ParsedDID, unUsed: Resolver, options: DIDResolutionOptions) -> Promise<DIDResolutionResult>
}

public func getResolver(options: ConfigurationOptions) -> [String:DIDResolverType] {
  return InfraDIDResolver(options: options).build()
}

// MARK: Resolver
  /**
   Main Resolver
   
   */
public class InfraDIDResolver {

  private var networks: ConfiguredNetworks
  private var noRevocationCheck: Bool = false
  private var deactivated: Bool = false
  private var resolveGroup = DispatchGroup.init()
  
  public init(options: ConfigurationOptions) {
    self.networks = configureResolverWithNetworks(conf: options)
    
    if options.noRevocationCheck {
      self.noRevocationCheck = true
    } else {
      self.noRevocationCheck = false
    }
  }
}

extension InfraDIDResolver: InfraDIDResolvable {
  // MARK: resolveMain
    /** Method
     
     Create DID ResolutionResult Using ParsedDID
     
     - Parameter did
     - Parameter ParsedDID
     - Parameter resolver
     - Parameter DIDResolutionResult
  
     - Throws: None
     
     - Returns: `Promise Value DIDResolutionResult`
     
     */
  public func resolve(did: String, parsed: ParsedDID, unUsed: Resolver, options: DIDResolutionOptions) -> Promise<DIDResolutionResult> {
    iPrint(parsed)
    let idSplit = parsed.id.split(separator: ":")
    
    if (idSplit.count != 2) {
      return Promise<DIDResolutionResult>.value(DIDResolutionResult(
        didResolutionMetadata: DIDResolutionMetadata(contentType: nil, errorDescription: .invalidDid,
                                                     message: "invalid did, needs network identifier part and id part (\(did))"),
        didDocument: nil,
        didDocumentMetaData: DIDDocumentMetaData()))
    }
    
    guard let network: ConfiguredNetwork = self.networks[String(idSplit[0])] else { return Promise<DIDResolutionResult>.value(DIDResolutionResult(didResolutionMetadata: DIDResolutionMetadata(contentType: nil, errorDescription: .unKnownNetwork, message: "no chain network configured for network identifier \(idSplit[0])"), didDocument: nil, didDocumentMetaData: DIDDocumentMetaData())) }
    
    do {
      let idInNetwork: String = String(idSplit[1])
      var resolvedDIDDoc = ResolvedDIDDocument(didDocument: DIDDocument(), deactivated: false)
      resolveGroup.enter()
      if idInNetwork.starts(with: "PUB_K1") || idInNetwork.starts(with: "PUB_R1") || idInNetwork.starts(with: "EOS") {
        let resolvedDid = self.resolvePubKeyDID(did: did, pubKey: idInNetwork, network: network)
        resolveGroup.wait()
        guard let resolvedDoc = resolvedDid.value else { return emptyResult }
        resolvedDIDDoc = resolvedDoc
      } else {
        let resolvedDid = self.resolveAccountDID(did: did, accountName: idInNetwork, network: network)
        resolveGroup.wait()
        guard let resolvedDoc = resolvedDid.value else { return emptyResult }
        resolvedDIDDoc = resolvedDoc
      }
      
      
      let status = resolvedDIDDoc.deactivated
      guard let document = resolvedDIDDoc.didDocument else { return Promise<DIDResolutionResult>.value(DIDResolutionResult())}
      
      return Promise<DIDResolutionResult>.value(DIDResolutionResult(didResolutionMetadata: DIDResolutionMetadata(contentType: "application/did+ld+json", errorDescription: nil, message: nil)
                                                                    , didDocument: document
                                                                    , didDocumentMetaData: DIDDocumentMetaData(created: nil, updated: nil, deactivated: status, versionId: nil, nextUpdate: nil, nextVersionId: nil, equivalentId: nil, canonicalId: nil)))
      
    }
    
    
    
  }
  
  // MARK: build
    /**
     Bound with DIDResolver
     
     - Throws: None
     
     - Returns: `Dictionary<String: DIDResolver>`
     
     */
  public func build() -> [String:DIDResolverType] {
    return ["infra": self.resolve]
  }
  
  // MARK: resolvePubKeyDID
    /**
        Resolved DIDDocument Based On PubKeyDID Using PromiseChain
     
     - Parameter did
     - Parameter pubKey
     - Parameter ConfigureNetwork
     
     - Returns: `Promise Value ResolvedDIDDocument`
     
     */
  private func resolvePubKeyDID(did: String, pubKey: String, network: ConfiguredNetwork) -> Promise<ResolvedDIDDocument> {
    guard let pubKeyData = try? Data(eosioPublicKey: pubKey) else { return emptyResolvedDocument }
    let pubKeyArray = [UInt8](pubKeyData)
    let sliceKey = pubKeyArray[1...pubKeyArray.count-1]
    
    
    let sliceKeyData = Data(sliceKey)
    let pubKeyIndex = sliceKeyData.hexEncodedString()
    
    guard let jsonRpc = network.jsonRPC else { return emptyResolvedDocument }
    
    return Promise { seal in
      firstly {
        jsonRpcFetchRows(rpc: jsonRpc, options: EosioRpcTableRowsRequest(scope: network.regisrtyContract, code: network.regisrtyContract, table: "pubkeydid", json: true, limit: 1, tableKey: nil, lowerBound: pubKeyIndex, upperBound: pubKeyIndex, indexPosition: "2", keyType: "sha256", encodeType: .hex, reverse: nil, showPayer: nil))
        
      }.then({ row in
        self.deactivatedCheck(row: row)
      }).then { row in
        jsonRpcFetchRows(rpc: jsonRpc, options: EosioRpcTableRowsRequest(scope: network.regisrtyContract, code: network.regisrtyContract, table: "pkdidowner", json: true, limit: 1, tableKey: nil, lowerBound: row["pkid"] as? String , upperBound: nil, indexPosition: "2", keyType: "i64", encodeType: .hex, reverse: nil, showPayer: nil))
      }.then { row in
        self.pubKeyParsing(keyAttr: row)
      }.done { (pubKey, row) in
        iPrint(self.deactivated)
        seal.fulfill(self.wrapDidDocument(did: did, controllerPubKey: pubKey, pkdidAttr: row, deactivated: self.deactivated))
        self.resolveGroup.leave()
      }.catch { error in
        switch error {
        case APIError.emptyError:
          iPrint(self.deactivated)
          seal.fulfill(self.wrapDidDocument(did: did, controllerPubKey: pubKeyData, pkdidAttr: [:], deactivated: self.deactivated))
          self.resolveGroup.leave()
        case APIError.parsingError:
          iPrint("parsing Error")
        case APIError.resultError:
          iPrint("Api Result Error")
        default:
          break
        }
      }
    }
  }
  
  // MARK: resolveAccountDID
    /** Method
        Resolved DIDDocument Based On AccountDID Using PromiseChain
     
     - Parameter did
     - Parameter accountName
     - Parameter ConfiguredNetwork
     
     - Returns: `Promise Value ResolvedDIDDocument`
     
     */
  private func resolveAccountDID(did: String, accountName: String, network: ConfiguredNetwork) -> Promise<ResolvedDIDDocument> {
    var activeKeyStr = ""
    
    guard let rpc = network.jsonRPC else { return emptyResolvedDocument }
    
    return Promise { seal in
      firstly {
        self.jsonRpcFetchAccountInfo(jsonRpc: rpc, accountName: accountName)
      }.compactMap({ activeKey in
        activeKeyStr = activeKey
      }).then {
        jsonRpcFetchRows(rpc: rpc, options: EosioRpcTableRowsRequest(scope: network.regisrtyContract, code: network.regisrtyContract, table: "accdidattr", json: true, limit: 1, tableKey: nil, lowerBound: accountName, upperBound: accountName, indexPosition: "1", keyType: "name", encodeType: .hex, reverse: nil, showPayer: nil))
      }.done { row in
        seal.fulfill(self.wrapDidDocument(did: did, controllerPubKey: try! Data(eosioPublicKey: activeKeyStr), pkdidAttr: row, deactivated: false))
        self.resolveGroup.leave()
      }.catch { error in
        iPrint(error.localizedDescription)
      }
      
    }
  }
  
  private func jsonRpcFetchAccountInfo(jsonRpc: EosioRpcProvider, accountName: String) -> Promise<String> {
    return Promise { seal in
      jsonRpc.getAccount(requestParameters: EosioRpcAccountRequest(accountName: accountName)) { result in
        switch result {
          
        case .success(let res):
          let permission = res.permissions
          guard let activePermission = permission.filter({$0.permName == "active"}).first,
                let keysAndWeight = activePermission.requiredAuth.keys.first  else { return }
          seal.fulfill(keysAndWeight.key)
          
        case .failure(_):
          seal.reject(APIError.resultError)
        }
      }
    }
  }
  
  
  private func wrapDidDocument(did: String, controllerPubKey: Data?, pkdidAttr: [String:Any], deactivated: Bool) -> ResolvedDIDDocument {
    guard let pubKey = controllerPubKey?.hexEncodedString() else { return ResolvedDIDDocument() }
    var baseDidDocument = DIDDocument(context: ["https://www.w3.org/ns/did/v1"], id: did, alsoKnownAs: nil, controller: nil, verificationMethod: [], service: nil, publicKey: nil, authentication: [])
    let publicKeys = [VerificationMethod(id: "\(did)#controller", type: verificationMethodTypes.EcdsaSecp256k1VerificationKey2019.rawValue, controller: did, publicKeyBase58: nil, publicKeyBase64: nil, publicKeyJwk: nil, publicKeyHex: pubKey, publicKeyMultibase: nil, blockchainAccountId: nil, ethereumAddress: nil)]
    
    let authentication = ["\(did)#controller"]
    var serviceEndpoints: [ServiceEndpoint] = []
    
    var serviceCount = 0
    
    if let attr = pkdidAttr["attr"] as? [String:String] {
      for (key, value) in attr {
        let split = key.split(separator: "/")
        if split.count > 0 {
          let attrType = split[0]
          switch attrType {
          case "svc":
            serviceCount += 1
            serviceEndpoints.append(ServiceEndpoint(id: "\(did)#service-\(serviceCount)",
                                                    type: split.count > 1 ? String(split[1]) : "AgentService"
                                                    , serviceEndpoint: value, description: nil))
            break
            
          default:
            break
          }
        }
      }
    }
  
    baseDidDocument.verificationMethod = publicKeys
    baseDidDocument.authentication = authentication
    
    if serviceEndpoints.count > 0 {
      baseDidDocument.service = serviceEndpoints
    }
    return ResolvedDIDDocument(didDocument: baseDidDocument, deactivated: deactivated)
  }
  
  
  private func deactivatedCheck(row: [String:Any]) -> Promise<[String:Any]> {
    iPrint("rawResponse Completed")
    return Promise { seal in
      if !(row.isEmpty) {
        if self.noRevocationCheck == false && row["nonce"] as? Double == 65535 {
          deactivated = true
          seal.fulfill(row)
        }
      } else {
        seal.reject(APIError.emptyError)
      }
    }
  }
  
  private func pubKeyParsing(keyAttr: [String:Any]) -> Promise<(Data, [String:Any])> {
    iPrint("keyParsing InProgressing")
    return Promise { seal in
      if let keyString = keyAttr["pk"] as? String ,
         let pubKey = try? Data(eosioPublicKey: keyString) {
        seal.fulfill((pubKey, keyAttr))
      }
      else { seal.reject(APIError.parsingError) }
    }
  }
  
}
