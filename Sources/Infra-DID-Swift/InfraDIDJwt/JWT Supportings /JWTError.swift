//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/11/29.
//

import Foundation

// MARK: JWTError

/**
 A struct representing the different errors that can be thrown by SwiftJWT
 
 - **Property with**
 
    - localizedDescription
    - internalError
    - message
 
 */

/// A struct representing the different errors that can be thrown by SwiftJWT
public struct JWTError: Error, Equatable {
  
  /// A human readable description of the error.
  public let localizedDescription: String
  
  private let internalError: InternalError?
  
  public var message: String?
  
  private enum InternalError {
    case invalidJWTString, failedVerification,
         osVersionToLow, invalidPrivateKey, invalidData,
         invalidKeyID, missingPEMHeaders, invalidArgument
  }
  
  /// Error when an invalid JWT String is provided
  public static let invalidJWTString = JWTError(localizedDescription: "Input was not a valid JWT String", internalError: .invalidJWTString)
  
  public static let invalidArgument = JWTError(localizedDescription: "invalid_argument: JWT expiresIn is not a number", internalError: .invalidArgument)
  
  /// Error when the JWT signiture fails verification.
  public static let failedVerification = JWTError(localizedDescription: "JWT verifier failed to verify the JWT String signiture", internalError: .failedVerification)
  
  /// Error when using RSA encryption with an OS version that is too low.
  public static let osVersionToLow = JWTError(localizedDescription: "macOS 10.12.0 (Sierra) or higher or iOS 10.0 or higher is required by CryptorRSA", internalError: .osVersionToLow)
  
  /// Error when an invalid private key is provided for RSA encryption.
  public static let invalidPrivateKey = JWTError(localizedDescription: "Provided private key could not be used to sign JWT", internalError: .invalidPrivateKey)
  
  /// Error when the provided Data cannot be decoded to a String
  public static let invalidUTF8Data = JWTError(localizedDescription: "Could not decode Data from UTF8 to String", internalError: .invalidData)
  
  /// Error when the KeyID field `kid` in the JWT header fails to generate a JWTSigner or JWTVerifier
  public static let invalidKeyID = JWTError(localizedDescription: "The JWT KeyID `kid` header failed to generate a JWTSigner/JWTVerifier", internalError: .invalidKeyID)
  
  /// Error when a PEM string is provided without the expected PEM headers/footers. (e.g. -----BEGIN PRIVATE KEY-----)
  public static let missingPEMHeaders = JWTError(localizedDescription: "The provided key did not have the expected PEM headers/footers", internalError: .missingPEMHeaders)
  
  //public static let customError = JWTError(localizedDescription: self.message, internalError: nil)
  
  private init(localizedDescription: String, internalError: InternalError) {
    self.localizedDescription = localizedDescription
    self.internalError = internalError
  }
  
  public init(localizedDescription: String) {
    self.localizedDescription = self.message != nil ? self.message! : localizedDescription
    //self.internalError = internalError
    self.internalError = nil
  }
  
  /// Function to check if JWTErrors are equal. Required for equatable protocol.
  public static func == (lhs: JWTError, rhs: JWTError) -> Bool {
    return lhs.internalError == rhs.internalError
  }
  
  /// Function to enable pattern matching against generic Errors.
  public static func ~= (lhs: JWTError, rhs: Error) -> Bool {
    guard let rhs = rhs as? JWTError else {
      return false
    }
    return lhs == rhs
  }
}
