//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/11/29.
//

import Foundation


// MARK: Claims
/**
 A protocol for representing the claims on a JSON web token.
 https://tools.ietf.org/html/rfc7519#section-4.1
### Usage Example: ###
```swift
struct AdminClaims: Claims {
    var sub: String
    var isAdmin: Bool
    var exp: Date?
}
 let jwt = JWT(claims: AdminClaims(sub: "Kitura", isAdmin: true, exp: Date(timeIntervalSinceNow: 3600)))
```
*/
public protocol Claims: Codable {
    
    /**
     The "exp" (expiration time) claim identifies the expiration time on
     or after which the JWT MUST NOT be accepted for processing.  The
     processing of the "exp" claim requires that the current date/time
     MUST be before the expiration date/time listed in the "exp" claim.
     Implementers MAY provide for some small leeway, usually no more than
     a few minutes, to account for clock skew.
     */
    var exp: Date? { get set}
    
    /**
     The "nbf" (not before) claim identifies the time before which the JWT
     MUST NOT be accepted for processing.  The processing of the "nbf"
     claim requires that the current date/time MUST be after or equal to
     the not-before date/time listed in the "nbf" claim.  Implementers MAY
     provide for some small leeway, usually no more than a few minutes, to
     account for clock skew.
     */
    var nbf: Date? { get set}
    
    /**
     The "iat" (issued at) claim identifies the time at which the JWT was
     issued.  This claim can be used to determine the age of the JWT.
     */
    var iat: Date? { get set}
    
    /// Encode the Claim object as a Base64 String.
    func encode() throws -> String
}
public extension Claims {
    
    var exp: Date? {
        return nil
    }
    
    var nbf: Date? {
        return nil
    }
    
    var iat: Date? {
        return nil
    }
    
    func encode() throws -> String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .secondsSince1970
        let data = try jsonEncoder.encode(self)      
        return base64urlEncodedString(data: data)
    }
}
