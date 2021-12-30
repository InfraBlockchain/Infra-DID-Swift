//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/11/29.
//



import Foundation
import CommonCrypto
import EosioSwiftEcc
import secp256k1
import PromiseKit
import EosioSwift

#if SWIFT_PACKAGE
import libtom
#endif

/**
 ###ECSigner###
 */
/// Class for ECDSA signing using ECC
class ECSigner: SignerAlgorithm {
  let name: String = "ECDSA"
  
  private let key: Data
  private let curve: EllipticCurveType
  
  init(key: Data, curve: EllipticCurveType) {
    self.key = key
    self.curve = curve
  }
  
  /**
   
   send utf8 encoded `header.claims` to BlueECC for signing
   
   - Parameter header - JWT Header
   - Parameter claims - JWT Claims
   
   */
  func sign(header: String, claims: String) throws -> String {
    
    let unsignedJWT = header + "." + claims
    guard let unsignedData = unsignedJWT.data(using: .utf8) else {
      throw JWTError.invalidJWTString
    }
    let signature = try sign(unsignedData)
    
    return unsignedJWT + "." + base64urlEncodedString(data: signature)
  }
  
  
  private func sign(_ data: Data) -> Data {
    
    let privateKey = try! secp256k1.Signing.PrivateKey.init(rawRepresentation: key)
    var sig = try! EosioEccSign.signWithK1(publicKey: privateKey.publicKey.rawRepresentation, privateKey: privateKey.rawRepresentation, data: data)
    
    if sig.count == 65 {
      sig = sig.dropFirst()
    }
    
    return sig
  }
}

/**
 ###ECVerifier###
 */
// Class for ECDSA verifying using BlueECC
class ECVerifier: VerifierAlgorithm {
  
  let name: String = "ECDSA"
  
  private let key: Data
  private let curve: EllipticCurveType
  
  init(key: Data, curve: EllipticCurveType) {
    self.key = key
    self.curve = curve
  }
  
  /**
   Method Verify a signed JWT String
   
   - Parameter JwtString
   
   - Returns: `isVerified`
   
   */
  func verify(jwt: String) -> Bool {
    let components = jwt.components(separatedBy: ".")
    
    if components.count == 3 {
      guard let signature = base64urlDecodedData(base64urlEncoded: components[2]),
            let jwtData = (components[0] + "." + components[1]).data(using: .utf8)
      else {
        return false
      }
      
      return try! self.verify(signature: signature, for: jwtData)
    } else {
      return false
    }
  }
  
  
  /**
   Method Verify Signature
   
   Send the base64URLencoded signature and `header.claims` to ECC for verification.
   
   - Parameter signature
   - Parameter data is message
   
   - Throws: `Base address of publicKey is nil`
   - Throws: `Cannot set curve on key`
   - Throws: `Cannot load private key and create public key`
   - Throws: `Base address of digest is nil`
   - Throws: `signature is Not valid`
   
   - Returns: `isVerified`
   
   */
  private func verify(signature: Data, for data: Data) throws -> Bool {
    do {
      
      var isValid: Bool = false
      
      register_all_ciphers()
      register_all_hashes()
      register_all_prngs()
      
      crypt_mp_init("ltm")
      
      var key = ecc_key()
      
      let hash = data.sha256
      
      try self.key.withUnsafeBytes({ rawBufferPointer in
        let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
        guard let pkbytes = bufferPointer.baseAddress else {
          throw JWTError(localizedDescription: "Base address of publicKey is nil.")
          //throw EosioError(.keySigningError, reason: "Base address of publicKey is nil.")
        }
        
        var keyCurve: UnsafePointer<ltc_ecc_curve>?
        guard ecc_find_curve("SECP256K1", &keyCurve) == CRYPT_OK else {
          throw JWTError(localizedDescription: "Base address of publicKey is nil.")
          
        }
        guard ecc_set_curve(keyCurve, &key) == CRYPT_OK else {
          throw JWTError(localizedDescription: "Cannot set curve on key.")
        }
        
        
        guard ecc_set_key(pkbytes, UInt(self.key.count), Int32(PK_PUBLIC.rawValue), &key) == CRYPT_OK else {
          throw JWTError(localizedDescription: "Cannot load private key and create public key.")
        }
        
        var status = Int32(0)
        
        iPrint("status is \(status)")
        
        try signature.withUnsafeBytes({ sigRawBufferPointer in
          let bufferPointer = sigRawBufferPointer.bindMemory(to: UInt8.self)
          guard let signatureBytes = bufferPointer.baseAddress else {
            throw JWTError(localizedDescription: "Base address of digest is nil.")
            
          }
          
          try hash.withUnsafeBytes({ hashRawBufferPointer in
            let bufferPointer = hashRawBufferPointer.bindMemory(to: UInt8.self)
            guard let hashBytes = bufferPointer.baseAddress else {
              throw JWTError(localizedDescription: "Base address of digest is nil.")
            }
            
            
            let verifyResult = ecc_verify_hash_ex(signatureBytes, UInt(signature.count), hashBytes, UInt(hash.count), LTC_ECCSIG_RFC7518, &status, &key)
            
            iPrint(verifyResult)
            iPrint("status is \(status)")
            guard verifyResult == CRYPT_OK, status != CRYPT_OK else { // signature is Not valid
              throw JWTError(localizedDescription: "Signature is Not valid")
              
            }
            isValid = true
          })
          
        })
        
      })
      
      return isValid
    }
    catch(let err) {
      iPrint(err.localizedDescription)
      return false
    }
  }
  
  
}

public struct JWTSigner {
  
  /// The name of the algorithm that will be set in the "alg" header
  let name: String
  
  let signerAlgorithm: SignerAlgorithm
  
  init(name: String, signerAlgorithm: SignerAlgorithm) {
    self.name = name
    self.signerAlgorithm = signerAlgorithm
  }
  
  func sign(header: String, claims: String) throws -> String {
    return try signerAlgorithm.sign(header: header, claims: claims)
  }
  
  /// Initialize a JWTSigner using the ECDSA SHA256 algorithm and the provided privateKey.
  /// - Parameter privateKey: The UTF8 encoded PEM private key, with either a "BEGIN EC PRIVATE KEY" or "BEGIN PRIVATE KEY" header.
  @available(OSX 10.13, iOS 11, tvOS 11.0, watchOS 4.0, *)
  public static func es256(privateKey: Data) -> JWTSigner {
    return JWTSigner(name: "ES256K", signerAlgorithm: ECSigner(key: privateKey, curve: .k1))
  }
  
}

public struct JWTVerifier {
  let verifierAlgorithm: VerifierAlgorithm
  
  init(verifierAlgorithm: VerifierAlgorithm) {
    self.verifierAlgorithm = verifierAlgorithm
  }
  
  func verify(jwt: String) -> Bool {
    return verifierAlgorithm.verify(jwt: jwt)
  }
  
  
  /// Initialize a JWTVerifier using the ECDSA SHA 256 algorithm and the provided public key.
  /// - Parameter publicKey: The UTF8 encoded PEM public key, with a "BEGIN PUBLIC KEY" header.
  @available(OSX 10.13, iOS 11, tvOS 11.0, watchOS 4.0, *)
  public static func es256(publicKey: Data) -> JWTVerifier {
    return JWTVerifier(verifierAlgorithm: ECVerifier(key: publicKey, curve: .k1))
  }
  public static let none = JWTVerifier(verifierAlgorithm: NoneAlgorithm())
  
}

struct NoneAlgorithm: VerifierAlgorithm, SignerAlgorithm {
  
  
  let name: String = "none"
  
  func sign(header: String, claims: String) -> String {
    return "\(header).\(claims)"
  }
  
  func verify(jwt: String) -> Bool {
    return true
  }
}
