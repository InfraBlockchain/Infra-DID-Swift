//
//  File.swift
//  
//
//  Created by CentLee on 2021/12/28.
//

import Foundation

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

extension Double {
    func toByteArray() -> [UInt8] {
        var array: [UInt8] = []
        
        array.append(UInt8((Int(self) >> 0) & 0xff))
        array.append(UInt8((Int(self) >> 8) & 0xff))

        //(Int(self) >> 0) & 0xff, ()
        return array
    }
}
