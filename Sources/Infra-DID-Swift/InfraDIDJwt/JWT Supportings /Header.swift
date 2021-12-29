//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/11/29.
//

import Foundation


// MARK: Header
/**
 A representation of a JSON Web Token header.
 https://tools.ietf.org/html/rfc7515#section-4.1
 
 - Property with:
 
    - typ
    - kid
 
 ### Usage Example: ###
 ```swift
 let myHeader = Header()
 let jwt = JWT(header: myHeader, claims: JwtPayloadStruct)
 ```
 
 */
public struct Header: Codable {
  
  /// Type Header Parameter
  public var typ: String?
  /// Algorithm Header Parameter
  public internal(set) var alg: String?
  /// JSON Web Token Set URL Header Parameter
  //    public var jku : String?
  //    /// JSON Web Key Header Parameter
  //    public var jwk: String?
  //    /// Key ID Header Parameter
  public var kid: String?
  //    /// X.509 URL Header Parameter
  //    public var x5u: String?
  //    /// X.509 Certificate Chain Header Parameter
  //    public var x5c: [String]?
  //    /// X.509 Certificate SHA-1 Thumbprint Header Parameter
  //    public var x5t: String?
  //    /// X.509 Certificate SHA-256 Thumbprint Header Parameter
  //    public var x5tS256: String?
  //    /// Content Type Header Parameter
  //    public var cty: String?
  //    /// Critical Header Parameter
  //    public var crit: [String]?
  
  public init(
    typ: String? = "JWT",
    alg: String? = "ES256K"
  ) {
    self.typ = typ
    self.alg = alg
  }
  
  func encode() throws -> String  {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.dateEncodingStrategy = .secondsSince1970
    guard let data = try? self.toJsonString().data(using: .utf8) else { return "" }
    return base64urlEncodedString(data: data)
  }
}
