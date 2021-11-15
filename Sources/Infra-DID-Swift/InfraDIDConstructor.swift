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


public class InfraDIDConstructor {
  
  private func generateRandomBytes(bytes: Int) -> Data? {

      var keyData = Data(count: bytes)
      let result = keyData.withUnsafeMutableBytes {
          SecRandomCopyBytes(kSecRandomDefault, bytes, $0.baseAddress!)
      }
      if result == errSecSuccess {
        return keyData
      } else {
          print("Problem generating random bytes")
          return nil
      }
  }
  
  public func createPubKeyDID(networkID: String) -> [String: String] {
    
    guard let pvData: Data = generateRandomBytes(bytes: 32) else { return [:]}
    let keyPair = try! secp256k1.Signing.PrivateKey.init(rawRepresentation: pvData)
    
    let privateKey: String = keyPair.rawRepresentation.toEosioK1PrivateKey
    let publicKey: String = keyPair.publicKey.rawRepresentation.toEosioK1PublicKey
    let did = "did:infra:\(networkID):\(publicKey)"
    
    
    return ["did": did, "publicKey": publicKey, "privateKey": privateKey]
  }
  
  public init() {

    guard let pvData: Data = generateRandomBytes(bytes: 32) else { return }
    
    let privateKey = try! secp256k1.Signing.PrivateKey.init(rawRepresentation: pvData)
    
    print(privateKey.rawRepresentation.toEosioK1PrivateKey)
    print(privateKey.publicKey.rawRepresentation.toEosioK1PublicKey)

  }
}
