//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/11/29.
//

import Foundation
import PromiseKit

let algorithms = ["ES256K"]

protocol SignerAlgorithm {
    /// A function to sign the header and claims of a JSON web token and return a signed JWT string.
    func sign(header: String, claims: String) throws -> String
}

protocol VerifierAlgorithm {
    /// A function to verify the signature of a JSON web token string is correct for the header and claims.
    func verify(jwt: String) -> Bool
    
}
