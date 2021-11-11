
import PMKFoundation
import EosioSwift
import Foundation

public struct Infra_DID_Swift {
    public private(set) var text = "Hello, World!"
  
    public init() {
      print(text)
      let value: String = Data.init().toEosioK1PublicKey
      print(value)
    }
}
