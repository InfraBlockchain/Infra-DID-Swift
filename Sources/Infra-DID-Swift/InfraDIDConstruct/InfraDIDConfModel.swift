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

/** Enum TransactionAction
 
 - Case with:
 
    - pksetattr
    - pkdidrevoke
    - pkdidclear
    - pkchowner
    - accsetattr
 
 */
public enum TransactionAction: String {
  case set = "pksetattr"
  case revoke = "pkdidrevoke"
  case clear = "pkdidclear"
  case changeOwner = "pkchowner"
  case setAccount = "accsetattr"
}

public struct IdConfiguration{
  public var did: String
  public var didOwnerPrivateKey: String // Contoller Key
  public var networkId: String
  public var registryContract: String
  public var rpcEndpoint: String
  public var jwtSigner: JWTSigner?
  public var txfeePayerAccount: String?
  public var txfeePayerPrivateKey: String?
  public var pubKeyDidSignDataPrefix: String?
  
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


public struct JwtIssuer {
  public var did: String
  public var signer: JWTSigner
  public var alg: String?
  
  public init(did: String = "", alg: String? = nil, signer: JWTSigner = JWTSigner.es256(privateKey: Data.init())) {
    self.did = did
    self.signer = signer
    self.alg = alg
  }
}

