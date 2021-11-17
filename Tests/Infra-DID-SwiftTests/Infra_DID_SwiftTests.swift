import XCTest
@testable import Infra_DID_Swift

final class Infra_DID_SwiftTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
      
       //1. DID 생성한다
      let a = InfraDIDConstructor.createPubKeyDID(networkID: "01")
      guard let did = a["did"], let pvKey = a["privateKey"], let netId = a["did"]?.split(separator: ":")[2]
            else { return }
      
      
      
      let idConfig: IdConfiguration = IdConfiguration(did: did, didOwnerPrivateKey: pvKey, networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io", jwtSigner: nil, txfeePayAccount: "qwexfhmvvdci", txfeePayerPrivateKey: "5KV84hXSJvu3nfqb9b1raRMnzvULaHH6Fsaz4xBZG2QbfPwMg76", pubKeyDidSignDataPrefix: nil)
      
      
      let didApi = InfraDIDConstructor(config: idConfig)
      
      didApi.setAttributePubKeyDID(key: "", value: "")
      //2. DID Api Configuration
      
      XCTAssertEqual(Infra_DID_Swift().text, "Hello, World!")
    }
}
