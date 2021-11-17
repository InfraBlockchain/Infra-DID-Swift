//
//  File.swift
//  
//
//  Created by SatGatLee on 2021/11/16.
//

import Foundation
import EosioSwift

public typealias Codable = Decodable & Encodable
//public typealias jsonRpc = EosioRpcProvider & EosioAbiProvider & EosioSoftkeySignatureProvider &                                       EosioAbieosSerializationProvider

func generateRandomBytes(bytes: Int) -> Data? {

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
