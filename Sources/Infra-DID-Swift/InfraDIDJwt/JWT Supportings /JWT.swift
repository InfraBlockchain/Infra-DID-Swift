//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/11/29.
//

import Foundation
import PromiseKit

// MARK: JWT

/**
 
 A struct representing the `Header` and `Claims` of a JSON Web Token.
 
 ### Usage Example: ###
 ```swift
 struct MyClaims: Claims {
    var name: String
 }
 let jwt = JWT(claims: MyClaims(name: "Kitura"))
 let key = "<PrivateKey>".data(using: .utf8)!
 let signedJWT: String? = try? jwt.sign(using: .rs256(key: key, keyType: .privateKey))
 ```
 */

public struct JWT<T: Claims>: Codable {
    
    /// The JWT header.
    public var header: Header
    
    /// The JWT claims
    public var claims: T
    
    /// Initialize a `JWT` instance from a `Header` and `Claims`.
    ///
    /// - Parameter header: A JSON Web Token header object.
    /// - Parameter claims: A JSON Web Token claims object.
    /// - Returns: A new instance of `JWT`.
    public init(header: Header = Header(), claims: T) {
        self.header = header
        self.claims = claims
    }
    
    /// Initialize a `JWT` instance from a JWT String.
    /// The signature will be verified using the provided JWTVerifier.
    /// The time based standard JWT claims will be verified with `validateClaims()`.
    /// If the string is not a valid JWT, or the verification fails, the initializer returns nil.
    ///
    /// - Parameter jwt: A String with the encoded and signed JWT.
    /// - Parameter verifier: The `JWTVerifier` used to verify the JWT.
    /// - Returns: An instance of `JWT` if the decoding succeeds.
    /// - Throws: `JWTError.invalidJWTString` if the provided String is not in the form mandated by the JWT specification.
    /// - Throws: `JWTError.failedVerification` if the verifier fails to verify the jwtString.
    /// - Throws: A DecodingError if the JSONDecoder throws an error while decoding the JWT.
    public init(jwtString: String, verifier: JWTVerifier = .none ) throws {
        let components = jwtString.components(separatedBy: ".")
      
        guard components.count == 2 || components.count == 3,
            let headerData = base64urlDecodedData(base64urlEncoded: components[0]),
            let claimsData = base64urlDecodedData(base64urlEncoded: components[1])
        else {
            throw JWTError.invalidJWTString
        }
        guard JWT.verify(jwtString, using: verifier) else {
            throw JWTError.failedVerification
        }
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        let header = try jsonDecoder.decode(Header.self, from: headerData)
        let claims = try jsonDecoder.decode(T.self, from: claimsData)
        self.header = header
        self.claims = claims
    }
    
    /// Sign the JWT using the given algorithm and encode the header, claims and signature as a JWT String.
    ///
    /// - Note: This function will set header.alg field to the name of the signing algorithm.
    ///
    /// - Parameter using algorithm: The algorithm to sign with.
    /// - Returns: A String with the encoded and signed JWT.
    /// - Throws: An EncodingError if the JSONEncoder throws an error while encoding the JWT.
    /// - Throws: `JWTError.osVersionToLow` if not using macOS 10.12.0 (Sierra) or iOS 10.0 or higher.
    /// - Throws: A Signing error if the jwtSigner is unable to sign the JWT with the provided key.
    public mutating func sign(using jwtSigner: JWTSigner) async throws -> String {
        var tempHeader = header
        tempHeader.alg = jwtSigner.name
        let headerString = try tempHeader.encode()
        let claimsString = try claims.encode()
        header.alg = tempHeader.alg
        return try await jwtSigner.sign(header: headerString, claims: claimsString)
//      iPrint(jwtSigner)
//        var tempHeader = header
//        tempHeader.alg = jwtSigner.name
//        let headerString = try tempHeader.encode()
//        let claimsString = try claims.encode()
//        header.alg = tempHeader.alg
//        return try jwtSigner.sign(header: headerString, claims: claimsString).value ?? ""
    }

    /// Verify the signature of the encoded JWT using the given algorithm.
    ///
    /// - Parameter jwt: A String with the encoded and signed JWT.
    /// - Parameter using algorithm: The algorithm to verify with.
    /// - Returns: A Bool indicating whether the verification was successful.
    public static func verify(_ jwt: String, using jwtVerifier: JWTVerifier) -> Bool {
        return jwtVerifier.verify(jwt: jwt)
    }

    /// Validate the time based standard JWT claims.
    /// This function checks that the "exp" (expiration time) is in the future
    /// and the "iat" (issued at) and "nbf" (not before) headers are in the past,
    ///
    /// - Parameter leeway: The time in seconds that the JWT can be invalid but still accepted to account for clock differences.
    /// - Returns: A value of `ValidateClaimsResult`.
//    public func validateClaims(leeway: TimeInterval = 0) -> ValidateClaimsResult {
//        if let expirationDate = claims.exp {
//            if expirationDate + leeway < Date() {
//                return .expired
//            }
//        }
//
//        if let notBeforeDate = claims.nbf {
//            if notBeforeDate > Date() + leeway {
//                return .notBefore
//            }
//        }
//
//        if let issuedAtDate = claims.iat {
//            if issuedAtDate > Date() + leeway {
//                return .issuedAt
//            }
//        }
//
//        return .success
//    }
}

