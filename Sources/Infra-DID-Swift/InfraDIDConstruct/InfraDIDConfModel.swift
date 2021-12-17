//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/11/16.
//

import Foundation
import secp256k1
import secp256k1_implementation
import EosioSwiftEcc


public struct TransactionDefaultSet {
  var actionName: TransactionAction
  var signKey: String
}

public enum TransactionAction: String {
  case set = "pksetattr"
  case revoke = "pkdidrevoke"
  case clear = "pkdidclear"
  case changeOwner = "pkchowner"
  case setAccount = "accsetattr"
}

public struct IdConfiguration{
  var did: String
  var didOwnerPrivateKey: String // Contoller Key
  var networkId: String
  var registryContract: String
  var rpcEndpoint: String
  var jwtSigner: JWTSigner?
  var txfeePayerAccount: String?
  var txfeePayerPrivateKey: String?
  var pubKeyDidSignDataPrefix: String?
  
  public init(did: String = "", didOwnerPrivateKey: String = "", networkId: String = "",
       registryContract: String = "", rpcEndpoint: String = "", jwtSigner: JWTSigner? = nil,
       txfeePayAccount: String? = nil, txfeePayerPrivateKey: String? = nil,
       pubKeyDidSignDataPrefix: String? = nil) {
    self.did = did
    self.didOwnerPrivateKey = didOwnerPrivateKey
    self.networkId = networkId
    self.registryContract = registryContract
    self.rpcEndpoint = rpcEndpoint
    self.jwtSigner = jwtSigner
    self.txfeePayerAccount = txfeePayAccount
    self.txfeePayerPrivateKey = txfeePayerPrivateKey
    self.pubKeyDidSignDataPrefix = pubKeyDidSignDataPrefix
  }
}

public struct JwtVcIssuer {
  var did: String
  var signer: JWTSigner //did jwt signer
  var alg: String?
  
  public init(did: String = "", alg: String? = nil, signer: JWTSigner = JWTSigner.es256(privateKey: Data.init())) {
    self.did = did
    self.signer = signer
    self.alg = alg
  }
}

