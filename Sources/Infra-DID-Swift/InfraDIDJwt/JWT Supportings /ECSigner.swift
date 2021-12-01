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
    func sign(header: String, claims: String) throws -> Promise<String> {
        let unsignedJWT = header + "." + claims
        guard let unsignedData = unsignedJWT.data(using: .utf8) else {
          throw JWTError.invalidJWTString
        }
        let signature = try sign(unsignedData)
        let signatureString = base64urlEncodedString(data: signature)
      return Promise<String>.value(header + "." + claims + "." + signatureString)
//      return Promise { seal in
//        firstly {
//          base64urlEncodedString(data: signature)
//        }.done { str in
//          seal.fulfill(header + "." + claims + "." + str)
//        }
//      }
    }
    
    // send utf8 encoded `header.claims` to BlueECC for signing
    private func sign(_ data: Data) throws -> Data {
        guard let keyString = String(data: key, encoding: .utf8) else {
          throw JWTError.invalidPrivateKey
        }
        let privateKey = try! secp256k1.Signing.PrivateKey.init(rawRepresentation: key)
    
        let signedData =  try! privateKey.signature(for: data)
      
      return signedData.rawRepresentation
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
        if components.count == 3 {
          
            guard let signature = base64urlDecodedData(base64urlEncoded: components[2]),
                let jwtData = (components[0] + "." + components[1]).data(using: .utf8)
                else {
                    return false
            }
            return self.verify(signature: signature, for: jwtData)
        } else {
            return false
        }
    }
    
    // Send the base64URLencoded signature and `header.claims` to BlueECC for verification.
    private func verify(signature: Data, for data: Data) -> Bool {
        do {
            guard let keyString = String(data: key, encoding: .utf8) else {
                return false
            }
            let r = signature.subdata(in: 0 ..< signature.count/2)
            let s = signature.subdata(in: signature.count/2 ..< signature.count)
          
            let signature = try! secp256k1.Signing.ECDSASignature.init(rawRepresentation: signature)
            let publicKey = try! secp256k1.Signing.PublicKey.init(rawRepresentation: self.key)
          //publicKey.isValidSignature(secp256k1.Signing.ECDSASignature.init(rawRepresentation: <#T##DataProtocol#>), for: <#T##DataProtocol#>)
            return publicKey.isValidSignature(signature, for: data)
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
    
    func sign(header: String, claims: String) throws -> Promise<String> {
        return try signerAlgorithm.sign(header: header, claims: claims)
    }
    
    /// Initialize a JWTSigner using the ECDSA SHA256 algorithm and the provided privateKey.
    /// - Parameter privateKey: The UTF8 encoded PEM private key, with either a "BEGIN EC PRIVATE KEY" or "BEGIN PRIVATE KEY" header.
    @available(OSX 10.13, iOS 11, tvOS 11.0, watchOS 4.0, *)
    public static func es256(privateKey: Data) -> JWTSigner {
        return JWTSigner(name: "ES256", signerAlgorithm: BlueECSigner(key: privateKey, curve: .k1))
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
    
    func sign(header: String, claims: String) -> Promise<String> {
      return Promise<String>.value("\(header).\(claims)")
    }
    
    func verify(jwt: String) -> Bool {
        return true
    }
}
//extension EcdsaSignature {
//  public func verify(plaintext: Data, using ecPublicKey: ECPublicKey) -> Bool {
////  #if os(Linux)
////      let md_ctx = EVP_MD_CTX_new_wrapper()
////      let evp_key = EVP_PKEY_new()
////      defer {
////          EVP_PKEY_free(evp_key)
////          EVP_MD_CTX_free_wrapper(md_ctx)
////      }
////      guard EVP_PKEY_set1_EC_KEY(evp_key, .make(optional: ecPublicKey.nativeKey)) == 1 else {
////          return false
////      }
////
////      EVP_DigestVerifyInit(md_ctx, nil, .make(optional: ecPublicKey.curve.signingAlgorithm), nil, evp_key)
////      guard plaintext.withUnsafeBytes({ (message: UnsafeRawBufferPointer) -> Int32 in
////          return EVP_DigestUpdate(md_ctx, message.baseAddress?.assumingMemoryBound(to: UInt8.self), plaintext.count)
////      }) == 1 else {
////          return false
////      }
////      let rc = self.asn1.withUnsafeBytes({ (sig: UnsafeRawBufferPointer) -> Int32 in
////      return SSL_EVP_digestVerifyFinal_wrapper(md_ctx, sig.baseAddress?.assumingMemoryBound(to: UInt8.self), self.asn1.count)
////      })
////      return rc == 1
////  #else
//    return EcdsaSignature.is
//      let hash = ecPublicKey.curve.digest(data: plaintext)
//
//      // Memory storage for error from SecKeyVerifySignature
//      var error: Unmanaged<CFError>? = nil
//      return SecKeyVerifySignature(ecPublicKey.nativeKey,
//                               ecPublicKey.curve.signingAlgorithm,
//                               hash as CFData,
//                               self.asn1 as CFData,
//                               &error)
//  #endif
//  }
//}
