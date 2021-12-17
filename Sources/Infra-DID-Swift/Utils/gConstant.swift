//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/11/16.
//

import Foundation
import EosioSwift
import PromiseKit

let emptyResult: Promise<DIDResolutionResult> = Promise<DIDResolutionResult>.value(DIDResolutionResult())
let emptyDocument: Promise<DIDDocument> = Promise<DIDDocument>.value(DIDDocument())
let emptyResolvedDocument: Promise<ResolvedDIDDocument> = Promise<ResolvedDIDDocument>.value(ResolvedDIDDocument())

public func generateRandomBytes(bytes: Int) -> Data? {

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

public func iPrint(_ objects:Any... , filename:String = #file,_ line:Int = #line, _ funcname:String = #function){ //debuging Print
  #if DEBUG
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "HH:mm:ss:SSS"
  let file = URL(string:filename)?.lastPathComponent.components(separatedBy: ".").first ?? ""
  print("💦info 🦋\(dateFormatter.string(from:Date())) 🌞\(file) 🍎line:\(line) 🌹\(funcname)🔥",terminator:"")
  for object in objects{
    print(object, terminator:"")
  }
  print("\n")
  #endif
}

public func base64urlEncodedString(data: Data) -> String {
    let result = data.base64EncodedString()
    return result.replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
}

public func base64urlDecodedData(base64urlEncoded: String) -> Data? {
    let paddingLength = 4 - base64urlEncoded.count % 4
    let padding = (paddingLength < 4) ? String(repeating: "=", count: paddingLength) : ""
    let base64EncodedString = base64urlEncoded
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
        + padding
    return Data(base64Encoded: base64EncodedString)
}

extension String{
  func matchingStrings(regex: String) -> [[String]] {
    guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
    let nsString = self as NSString
    let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
    return results.map { result in
      (0..<result.numberOfRanges).map {
        result.range(at: $0).location != NSNotFound
        ? nsString.substring(with: result.range(at: $0))
        : ""
      }
    }
  }
}
