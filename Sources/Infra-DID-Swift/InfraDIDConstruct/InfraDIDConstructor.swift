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
import EosioSwiftSoftkeySignatureProvider
import EosioSwiftAbieosSerializationProvider


/** Protocol InfraDIDConfApiDependency
 
 - Method actionPubKeyDID
 
 - Parameter with:
 
    - actionName
    - key
    - value
    - newKey
 
 */
protocol InfraDIDConfApiDependency {
  
  func actionPubKeyDID(actionName: TransactionAction, key: String,
                       value: String, newKey: String)
}

/** Struct InfraDIDConstructor
 
 - Property with:
 
    - idConfig
    - defaultPubKeyDidSignDataPrefix
    - didPubKey
    - didAccount
    - did
    - jsonRpc
    - rpcGroup
    - didOwnerPrivateKeyObjc
    - sigProviderPrivKeys
 
 */
public class InfraDIDConstructor {
  
  private var idConfig = IdConfiguration() //default Struct
  
  private let defaultPubKeyDidSignDataPrefix = "infra-mainnet"
  
  private var didPubKey: String?
  private var didAccount: String?
  private var did: String = ""
  private var jsonRpc: EosioRpcProvider?
  private var rpcGroup = DispatchGroup.init()
  
  private var didOwnerPrivateKeyObjc: secp256k1.Signing.PrivateKey?
  private var sigProviderPrivKeys: [String] = []
  
  
  public init(config: IdConfiguration) {
    //first initialized All removed
    idConfig = config
    
    self.idConfig.did = config.did
    
    let didSplit = config.did.split(separator: ":")
    
    guard didSplit.count == 4 else { return }
    
    let idNetwork = String(didSplit[3])
    
    if (idNetwork.starts(with: "PUB_K1") || idNetwork.starts(with: "PUB_R1") || idNetwork.starts(with: "EOS")) {
      self.didPubKey = idNetwork
    } else {
      self.didAccount = idNetwork
    }
    
    self.idConfig.registryContract = config.registryContract
    
    let rpc: EosioRpcProvider = EosioRpcProvider(endpoint: URL(string:config.rpcEndpoint)!)
    
    self.jsonRpc = rpc
    
    let dataPvKey = try! Data(eosioPrivateKey: config.didOwnerPrivateKey)
    let keyPair = try! secp256k1.Signing.PrivateKey.init(rawRepresentation: dataPvKey)
    self.didOwnerPrivateKeyObjc = keyPair
    
    sigProviderPrivKeys.append(config.didOwnerPrivateKey)
    if (config.txfeePayerAccount != nil) && (config.txfeePayerPrivateKey != nil) {
      guard let key: String = config.txfeePayerPrivateKey else {return}
      
      sigProviderPrivKeys.append(key) // for get_required_keys
      idConfig.txfeePayerAccount = config.txfeePayerAccount
    }
    
    idConfig.pubKeyDidSignDataPrefix = config.pubKeyDidSignDataPrefix ?? defaultPubKeyDidSignDataPrefix
    
    if idConfig.jwtSigner == nil {
      let signer = JWTSigner.es256(privateKey: dataPvKey)
      self.idConfig.jwtSigner = signer
    } else {
      self.idConfig.jwtSigner = config.jwtSigner
    }
  }
  
  /** Method to Create DID based on Secp256k1
   
   - Parameter with: NetworkID for DID creation
   
   - Throws: None
   
   - Returns: DID Parsing Dictionary
   
   */

  static public func createPubKeyDID(networkID: String) -> [String: String] {
    
    guard let pvData: Data = generateRandomBytes(bytes: 32),
          let keyPair = try? secp256k1.Signing.PrivateKey.init(rawRepresentation: pvData) else { return [:] }
    
    let privateKey: String = keyPair.rawRepresentation.toEosioK1PrivateKey
    let publicKey: String = keyPair.publicKey.rawRepresentation.toEosioK1PublicKey
    let did = "did:infra:\(networkID):\(publicKey)"
    
    return ["did": did, "publicKey": publicKey, "privateKey": privateKey]
  }
}



extension InfraDIDConstructor: InfraDIDConfApiDependency {
  
  /** Method Get Nonce from the table of the corresponding did in the blockchain
   
   - Parameter with: NetworkID for DID creation
   
   - Throws: None
   
   - Returns: DID Parsing Dictionary
   
   */
  private func getNonceForPubKeyDid() -> Promise<Double> {
    guard let pubKey: String = self.didPubKey, let jsonRPC = self.jsonRpc else { return Promise<Double>.value(0.0) }
    let dataPubKey = try! Data(eosioPublicKey: pubKey)
    let pubKeyArray = [UInt8](dataPubKey)
    let sliceKey = pubKeyArray[1...pubKeyArray.count-1]
    
    let sliceKeyData = Data(sliceKey)
    
    let options: EosioRpcTableRowsRequest = EosioRpcTableRowsRequest(scope: self.idConfig.registryContract, code: self.idConfig.registryContract, table: "pubkeydid", json: true, limit: 1, tableKey: nil, lowerBound: sliceKeyData.hexEncodedString(), upperBound: sliceKeyData.hexEncodedString(), indexPosition: "2", keyType: "sha256", encodeType: .dec, reverse: false, showPayer: false)
    
    return Promise { seal in
      
      firstly {
        jsonRpcFetchRows(rpc: jsonRPC, options: options)
      }
      .done { row in
        if let rowNonce = row["nonce"] as? Double {
          seal.fulfill(rowNonce)
          self.rpcGroup.leave()
        } else {
          seal.fulfill(0.0)
          self.rpcGroup.leave()
        }
      }.catch { error in
        switch error {
        case APIError.emptyError:
          seal.fulfill(0.0)
          self.rpcGroup.leave()
        default:
          self.rpcGroup.leave()
          break
        }
      }
      self.rpcGroup.wait()
    }
    
  }
  
  public func actionPubKeyDID(actionName: TransactionAction, key: String = "",
                              value: String = "", newKey: String = "") {
    var bufArray: [UInt8] = [] //digest buffer initialize
    
    guard let keyPair = self.didOwnerPrivateKeyObjc else { return }
    self.rpcGroup.enter()
    
    let nonceValue = getNonceForPubKeyDid()
    
    ///Create UInt8 ByteArray
    if let nonce = nonceValue.value,
       let prefixData = self.defaultPubKeyDidSignDataPrefix.data(using: .utf8),
       let actNameData = actionName.rawValue.data(using: .utf8),
       
        let keyData = key.data(using: .utf8),
       let valueData = value.data(using: .utf8),
       let changeKeyData = newKey.data(using: .utf8)
    {
      bufArray.append(contentsOf: prefixData) // 13
      bufArray.append(contentsOf: actNameData) // 9
      
      bufArray.append(UInt8(0)) // k1 Type == 0 , R1 Type == 1
      bufArray.append(contentsOf: keyPair.publicKey.rawRepresentation)
      bufArray.append(contentsOf: nonce.toByteArray())
      bufArray.append(contentsOf: keyData) // 20
      bufArray.append(contentsOf: valueData) // 33
      bufArray.append(contentsOf: changeKeyData)
    }
    
    ///publicKeyData is Only 65 Bytes(unCompressedKey) for Recover
    let publicKeyData = try! EccRecoverKey.recoverPublicKey(privateKey: keyPair.rawRepresentation, curve: .k1) // uncompressedKey
    
    ///Ecdsa Sign Secp256k1
    let signature = try? EosioEccSign.signWithK1(publicKey: publicKeyData, privateKey: keyPair.rawRepresentation, data: Data(bufArray))
    
    guard let sign = signature, let actor = self.idConfig.txfeePayerAccount, let pubKey = self.didPubKey else { return }
    
    var action: EosioTransaction.Action?
    
    self.rpcGroup.enter()
    
    switch actionName {
    case .set:
      action = try! EosioTransaction.Action.init(account: EosioName(self.idConfig.registryContract), name: EosioName(actionName.rawValue), authorization: [EosioTransaction.Action.Authorization.init(actor: EosioName(actor), permission: EosioName("active"))],
                                                 data: ["pk": keyPair.publicKey.rawRepresentation.toEosioLegacyPublicKey, "key": key, "value": value, "sig": sign.toEosioK1Signature, "ram_payer": actor])
    case .changeOwner:
      action = try! EosioTransaction.Action.init(account: self.idConfig.registryContract, name: actionName.rawValue, authorization: [EosioTransaction.Action.Authorization.init(actor: actor, permission: "active")],
                                                 data: ["pk": pubKey, "new_owner_pk": newKey, "sig": sign.toEosioK1Signature, "ram_payer": actor])
    case .revoke:
      action = try! EosioTransaction.Action.init(account: self.idConfig.registryContract, name: actionName.rawValue, authorization: [EosioTransaction.Action.Authorization.init(actor: actor, permission: "active")],
                                                 data: ["pk": pubKey, "sig": sign.toEosioK1Signature, "ram_payer": actor])
    case .clear:
      action = try! EosioTransaction.Action.init(account: EosioName(self.idConfig.registryContract), name: EosioName(actionName.rawValue), authorization: [EosioTransaction.Action.Authorization.init(actor: EosioName(actor), permission: EosioName("active"))],
                                                 data: ["pk": pubKey, "sig": sign.toEosioK1Signature])
    case .setAccount:
      guard let account = self.didAccount else { return }
      action = try! EosioTransaction.Action.init(account: self.idConfig.registryContract, name: actionName.rawValue, authorization: [EosioTransaction.Action.Authorization.init(actor: actor, permission: "active")],
                                                 data: ["account": account, "key": key, "value": value])
    }
    guard let transactionAction = action else { return }
    self.actionTransaction(action: transactionAction)
  }
  
  /** Method ActionTransaction
   
   - Parameter with: ActionName
   
   - Throws: None
   
   - Returns: None
   
   */
  private func actionTransaction(action: EosioTransaction.Action)  {
    let transaction = EosioTransaction.init()
    
    transaction.config.expireSeconds = 60
    transaction.config.blocksBehind = 3
    transaction.rpcProvider = self.jsonRpc
    
    transaction.signatureProvider = try! EosioSoftkeySignatureProvider(privateKeys: sigProviderPrivKeys)
    transaction.serializationProvider = EosioAbieosSerializationProvider()
    transaction.add(action: action)
    
    transaction.signBroadCastWithGetBlock { result in
      switch result {
      case .success(let isSuccess):
        iPrint(isSuccess)
        self.rpcGroup.leave()
      case .failure(let err):
        iPrint(err.localizedDescription)
        self.rpcGroup.leave()
      }
    }
    
    self.rpcGroup.wait()
  }
  
  /** Method Get Issuer
   
   - Parameter with: None
   
   - Throws: None
   
   - Returns: JwtIssuer
   
   */
  public func getJWTIssuer() -> JwtIssuer {
    guard let pvKey: Data = try? Data(eosioPrivateKey: self.idConfig.didOwnerPrivateKey) else { return JwtIssuer() }
    let signer: JWTSigner = JWTSigner.es256(privateKey: pvKey)
    return JwtIssuer(did: self.idConfig.did, alg: "ES256K", signer: signer)
  }
}
