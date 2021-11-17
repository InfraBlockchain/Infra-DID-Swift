//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/11/11.
//

import Foundation
import EosioSwift
import secp256k1
import secp256k1_implementation
import EosioSwiftEcc
import PromiseKit
import OHHTTPStubsSwift

protocol InfraDIDConfApiDependency { // method Construction & Manipulation DID
  

  func setAttributePubKeyDID(key: String, value: String)
  
}


public class InfraDIDConstructor {
  
  private var idConfig = IdConfiguration() //default Struct
  
  private let defaultPubKeyDidSignDataPrefix = "infra-mainnet"
  
  private var didPubKey: String?
  private var didAccount: String?
  private var did: String = ""
  private var jsonRpc: EosioRpcProvider?
  
  private var currentCurveType: EllipticCurveType = EllipticCurveType.k1
  
  private var didOwnerPrivateKeyObjc: secp256k1.Signing.PrivateKey?
  
  
  
  public init(config: IdConfiguration) {
    //first initialized All removed
    idConfig = config
    
    self.idConfig.did = config.did
    
    
    let didSplit = config.did.split(separator: ":")
    
    guard didSplit.count == 4 else { return }
    guard currentCurveType == .k1 else { return }
    
    let idNetwork = String(didSplit[3])
    
    if (idNetwork.starts(with: "PUB_K1") || idNetwork.starts(with: "PUB_R1") || idNetwork.starts(with: "EOS")) {
      self.didPubKey = idNetwork
    } else {
      self.didAccount = idNetwork
    }
    
    self.idConfig.registryContract = config.registryContract
    
    let rpc: EosioRpcProvider = EosioRpcProvider(endpoint: URL(string:config.rpcEndpoint)!)
    
    
    iPrint(URL(string:config.rpcEndpoint)!)
    self.jsonRpc = rpc

    let dataPvKey = try! Data(eosioPrivateKey: config.didOwnerPrivateKey)
    let keyPair = try! secp256k1.Signing.PrivateKey.init(rawRepresentation: dataPvKey)
    self.didOwnerPrivateKeyObjc = keyPair
    
    var sigProviderPrivKeys: [String] = []
    sigProviderPrivKeys.append(config.didOwnerPrivateKey)
    if (config.txfeePayerAccount != nil) && (config.txfeePayerPrivateKey != nil) {
      guard let key: String = config.txfeePayerPrivateKey else {return}
      
      sigProviderPrivKeys.append(key)
      idConfig.txfeePayerAccount = config.txfeePayerAccount
    }
    
    idConfig.pubKeyDidSignDataPrefix = config.pubKeyDidSignDataPrefix ?? defaultPubKeyDidSignDataPrefix
    
    //////////////////////// Setting Finish
  }
  
  static func createPubKeyDID(networkID: String) -> [String: String] {
    
    guard let pvData: Data = generateRandomBytes(bytes: 32) else { return [:] }
    let keyPair = try! secp256k1.Signing.PrivateKey.init(rawRepresentation: pvData)
    
    
    let privateKey: String = keyPair.rawRepresentation.toEosioK1PrivateKey
    let publicKey: String = keyPair.publicKey.rawRepresentation.toEosioK1PublicKey
    let did = "did:infra:\(networkID):\(publicKey)"
    
    return ["did": did, "publicKey": publicKey, "privateKey": privateKey]
  }
  
}



extension InfraDIDConstructor: InfraDIDConfApiDependency {
  
  private func getNonceForPubKeyDid() -> Promise<Double> {
    
    guard let pubKey: String = self.didPubKey, let jsonRPC = self.jsonRpc else { return Promise<Double>.value(0.0) }
    let dataPubKey = try! Data(eosioPublicKey: pubKey)
    let pubKeyArray = [UInt8](dataPubKey)
    let sliceKey = pubKeyArray[1...pubKeyArray.count-1]
    
    
    let sliceKeyData = Data(sliceKey)
    
    let options: EosioRpcTableRowsRequest = EosioRpcTableRowsRequest(scope: self.idConfig.registryContract, code: self.idConfig.registryContract, table: "pubkeydid", json: true, limit: 1, tableKey: nil, lowerBound: sliceKeyData.hexEncodedString(), upperBound: sliceKeyData.hexEncodedString(), indexPosition: "2", keyType: "sha256", encodeType: .hex, reverse: false, showPayer: false)
    
    return Promise { seal in
      firstly {
        jsonRPC.getTableRows(.promise, requestParameters: options)
      }.done {
        if let row = $0.rows[0] as? [String: Any],
           let nonceValue = row["nonce"] as? Double
        {
          seal.fulfill(nonceValue)
        } else {
          seal.fulfill(0.0)
          print(NSError.init())
        }
      }
    }
  }
  
  private func digestForPubKeyDIDSetAttributeSig(pubKey: String, key: String, value: String, nonce: Double) {
    
  }
  
  func setAttributePubKeyDID(key: String, value: String) {
    let actionName: String = "pksetattr"
    var bufArray: [UInt8] = []
    
    
    firstly {
      getNonceForPubKeyDid()
    }
    .done { nonce in
      guard let prefix = self.defaultPubKeyDidSignDataPrefix.data(using: .utf8),
            let actName = actionName.data(using: .utf8),
            let key = key.data(using: .utf8),
            let value = value.data(using: .utf8),
            let pubKey = self.didPubKey?.data(using: .utf8)
      else { return }
      
      
      bufArray.append(contentsOf: prefix)
      bufArray.append(contentsOf: actName)
      bufArray.append(contentsOf: key)
      bufArray.append(contentsOf: value)
      bufArray.append(contentsOf: pubKey)
      bufArray.append(UInt8.init(nonce))
      
      // bufArray hash And Digest
      let digest: SHA256Digest = SHA256.hash(data: bufArray)
      let signature = try! self.didOwnerPrivateKeyObjc?.signature(for: digest)
      
      guard let sign = signature, let actor = self.idConfig.txfeePayerAccount else { return }
      
      let action: EosioTransaction.Action = try! EosioTransaction.Action.init(account: self.idConfig.registryContract, name: actionName, authorization: [EosioTransaction.Action.Authorization.init(actor: actor, permission: "active")],
          data: ["pk": self.didPubKey, "key": key, "value": value, "sig": sign.rawRepresentation.toEosioK1Signature, "ram_payer": self.idConfig.txfeePayerAccount])
      
      let transaction = EosioTransaction.init()
      
      transaction.config.expireSeconds = 30
      transaction.config.blocksBehind = 3
      
      transaction.add(action: action)
      
      transaction.signAndBroadcast { result in
        switch result {
        case .success(let isSuccess):
          iPrint(isSuccess)
        case .failure(let err):
          iPrint(err.localizedDescription)
        }
      }
    }
    //transaction add
  }
}
