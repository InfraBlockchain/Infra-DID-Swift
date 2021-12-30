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


/**
 Method Generate Secure Random Bytes
 
 - Parameter bytes is 32 Byte
 
 - Returns: `Byte Data`
 
 */
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

//Debug Printing
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



//Eosio Chain Func
public func jsonRpcFetchRows(rpc: EosioRpcProvider, options: EosioRpcTableRowsRequest) -> Promise<[String:Any]> {
  
  return Promise { seal in
    rpc.getTableRows(requestParameters: options) { result in
      switch result {
      case .success(let res):
        iPrint(res)
        if !(res.rows.isEmpty) {
          if let row = res.rows[0] as? [String:Any] {
            iPrint("response Completed")
            seal.fulfill(row)
          }
        } else {
          seal.reject(APIError.emptyError)
        }
      case .failure(let err):
        iPrint(err.localizedDescription)
        seal.reject(APIError.resultError)
      }
    }
  }
}

