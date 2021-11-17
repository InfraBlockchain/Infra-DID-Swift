//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/11/16.
//

import Foundation
import secp256k1
import secp256k1_implementation

public struct IdConfiguration{
  var did: String
  var didOwnerPrivateKey: String // Contoller Key
  var networkId: String
  var registryContract: String
  var rpcEndpoint: String
  var jwtSigner: AnyObject?
  var txfeePayerAccount: String?
  var txfeePayerPrivateKey: String?
  var pubKeyDidSignDataPrefix: String?
  //var keyPair: secp256k1.Signing.PrivateKey?
  
  
  init(did: String = "", didOwnerPrivateKey: String = "", networkId: String = "",
       registryContract: String = "", rpcEndpoint: String = "", jwtSigner: AnyObject? = nil,
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
    //self.keyPair = keyPair
  }
}

public struct JwtVcIssuer {
  var did: String
  //var Signer: Signer //did jwt signer
  var alg: String?
  
  init(did: String = "", alg: String? = nil) {
    self.did = did
    self.alg = alg
  }
}

