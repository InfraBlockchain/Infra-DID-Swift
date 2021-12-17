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

// Class for ECDSA signing using BlueECC
@available(OSX 10.13, iOS 11, tvOS 11.0, watchOS 4.0, *)
class BlueECSigner: SignerAlgorithm {
  let name: String = "ECDSA"
  
  private let key: Data
  private let curve: EllipticCurveType
  
  // Initialize a signer using .utf8 encoded PEM private key.
  init(key: Data, curve: EllipticCurveType) {
    self.key = key
    self.curve = curve
  }
  
  // Sign the header and claims to produce a signed JWT String
  
  func sign(header: String, claims: String) async throws -> String {
    
    let unsignedJWT = header + "." + claims
    guard let unsignedData = unsignedJWT.data(using: .utf8) else {
      throw JWTError.invalidJWTString
    }
    let signature = try sign(unsignedData)
    
    return unsignedJWT + "." + base64urlEncodedString(data: signature)
  }
  
  // send utf8 encoded `header.claims` to BlueECC for signing
  private func sign(_ data: Data) throws -> Data {
    
    iPrint(key.count)
    
    let privateKey = try! secp256k1.Signing.PrivateKey.init(rawRepresentation: key)
    var sig = try! EosioEccSign.signWithK1(publicKey: privateKey.publicKey.rawRepresentation, privateKey: privateKey.rawRepresentation, data: data)
    
    if sig.count == 65 {
      sig = sig.dropFirst()
    }
    
    return sig//signedData.rawRepresentation//signedData.rawRepresentation
  }
}

// Class for ECDSA verifying using BlueECC
@available(OSX 10.13, iOS 11, tvOS 11.0, watchOS 4.0, *)
class BlueECVerifier: VerifierAlgorithm {
  
  let name: String = "ECDSA"
  
  private let key: Data
  private let curve: EllipticCurveType
  
  // Initialize a verifier using .utf8 encoded PEM public key.
  init(key: Data, curve: EllipticCurveType) {
    self.key = key
    self.curve = curve
  }
  
  // Verify a signed JWT String
  func verify(jwt: String) -> Bool {
    let components = jwt.components(separatedBy: ".")
    let jsonDecoder = JSONDecoder()
    
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
  
  // Send the base64URLencoded signature and `header.claims` to BlueECC for verification.
  private func verify(signature: Data, for data: Data) throws -> Bool {
    do {
      iPrint(signature)
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
              throw JWTError(localizedDescription: "signature is Not valid")
              
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
  
  func sign(header: String, claims: String) async throws -> String {
    return try await signerAlgorithm.sign(header: header, claims: claims)
  }
  
  /// Initialize a JWTSigner using the ECDSA SHA256 algorithm and the provided privateKey.
  /// - Parameter privateKey: The UTF8 encoded PEM private key, with either a "BEGIN EC PRIVATE KEY" or "BEGIN PRIVATE KEY" header.
  @available(OSX 10.13, iOS 11, tvOS 11.0, watchOS 4.0, *)
  public static func es256(privateKey: Data) -> JWTSigner {
    return JWTSigner(name: "ES256K", signerAlgorithm: BlueECSigner(key: privateKey, curve: .k1))
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
    return JWTVerifier(verifierAlgorithm: BlueECVerifier(key: publicKey, curve: .k1))
  }
  public static let none = JWTVerifier(verifierAlgorithm: NoneAlgorithm())
  
}

struct NoneAlgorithm: VerifierAlgorithm, SignerAlgorithm {
  
  
  let name: String = "none"
  
  func sign(header: String, claims: String) async -> String {
    return "\(header).\(claims)"
  }
  
  func verify(jwt: String) -> Bool {
    return true
  }
}


public func signK1(publicKey: Data, privateKey: Data, data: Data) throws -> Data {
  register_all_ciphers()
  register_all_hashes()
  register_all_prngs()
  
  // This is important or we will fault trying to invoke the math libraries!
  crypt_mp_init("ltm")
  
  var yarrowState = prng_state()
  guard rng_make_prng(128, find_prng("yarrow"), &yarrowState, nil) == CRYPT_OK else {
    throw EosioError(.keySigningError, reason: "Error initializing signing.")
  }
  
  var key: ecc_key = ecc_key()
  
  let digest = data.sha256
  var recid = Int32(0)
  var signature: Data?
  var attemptsRequired = 0
  
  try privateKey.withUnsafeBytes { rawBufferPointer in
    let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
    guard let pkbytes = bufferPointer.baseAddress else {
      throw EosioError(.keySigningError, reason: "Base address of privateKey is nil.")
    }
    
    var keyCurve: UnsafePointer<ltc_ecc_curve>?
    guard ecc_find_curve("SECP256K1", &keyCurve) == CRYPT_OK else {
      throw EosioError(.keySigningError, reason: "Curve not found.")
    }
    guard ecc_set_curve(keyCurve, &key) == CRYPT_OK else {
      throw EosioError(.keySigningError, reason: "Cannot set curve on key.")
    }
    
    guard ecc_set_key(pkbytes, UInt(privateKey.count), Int32(PK_PRIVATE.rawValue), &key) == CRYPT_OK else {
      throw EosioError(.keySigningError, reason: "Cannot load private key and create public key.")
    }
    
    try digest.withUnsafeBytes { rawBufferPointer in
      let bufferPointer = rawBufferPointer.bindMemory(to: UInt8.self)
      guard let digestBytes = bufferPointer.baseAddress else {
        throw EosioError(.keySigningError, reason: "Base address of digest is nil.")
      }
      
      let bufSize = Int(1000)
      let outbuf = UnsafeMutablePointer<UInt8>.allocate(capacity: bufSize)
      var outbufLen = UInt(bufSize)
      defer {
        outbuf.deinitialize(count: bufSize)
        outbuf.deallocate()
      }
      outbuf.initialize(repeating: 0, count: bufSize)
      let sigResult = ecc_sign_hash_ex(digestBytes,
                                       UInt(digest.count),
                                       outbuf,
                                       &outbufLen,
                                       &yarrowState,
                                       find_prng("yarrow"),
                                       LTC_ECCSIG_RFC7518,
                                       &recid,
                                       &key)
      guard sigResult == CRYPT_OK else {
        throw EosioError(.keySigningError, reason: "Error in keysigning attemp.")
      }
      let sig = Data(bytes: outbuf, count: Int(outbufLen))
      signature = sig
    }
  }
  if let signature = signature {
    return signature
  } else {
    throw EosioError(.keySigningError, reason: "Unable to create canonical signature after attempts")
  }
}

