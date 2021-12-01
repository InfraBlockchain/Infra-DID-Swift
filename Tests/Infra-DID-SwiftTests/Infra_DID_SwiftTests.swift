import XCTest
@testable import Infra_DID_Swift
import PromiseKit

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
    
    didApi.setAttributePubKeyDID(action: .clear)
    
    //"did:infra:sentinel:PUB_K1_7pM9qiBuHWF6WqRSjPTMfVYKV5ZFRavK4PkUq4oFhqi9Z46mWc"
    
    let infraDidResolver = getResolver(options: MultiNetworkConfiguration(networks: [NetworkConfiguration(networkId: "sentinel", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io")], noRevocationCheck: false))
    
    let didResolver = Resolver(registry: ResolverRegistry(methodName: infraDidResolver), options: ResolverOptions(cache: ResolverOptionsType.bool(true), legacyResolver: nil))
    
 //   guard let baseData = base64urlDecodedData(base64urlEncoded: "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NksifQ.eyJpYXQiOjE0ODUzMjExMzMsImRpZCI6ImRpZDpldGhyOjB4ZjNiZWFjMzBjNDk4ZDllMjY4NjVmMzRmY2FhNTdkYmI5MzViMGQ3NCIsImlzcyI6Imh0dHBzOi8vc2VsZi1pc3N1ZWQubWUifQ.2osZdSAqh8do2opJ-1RMXlDm8axkDSLhPS-bpeb4cOOtUEnF0i5fdZv7TC_aG2if-YmKlvRFMqrX5VaBBlrBXA") else { return }
    //let jwtString = try! baseData.toJsonString()
 //   iPrint(jwtString)
    iPrint(decodeJws(jws: "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NksifQ.eyJpYXQiOjE0ODUzMjExMzMsImRpZCI6ImRpZDpldGhyOjB4ZjNiZWFjMzBjNDk4ZDllMjY4NjVmMzRmY2FhNTdkYmI5MzViMGQ3NCIsImlzcyI6Imh0dHBzOi8vc2VsZi1pc3N1ZWQubWUifQ.2osZdSAqh8do2opJ-1RMXlDm8axkDSLhPS-bpeb4cOOtUEnF0i5fdZv7TC_aG2if-YmKlvRFMqrX5VaBBlrBXA"))
    //let data = try JSONDecoder().decode(JwtPayload.self, from: baseData)
    //iPrint(data)
    //let jwsDecoded = [UInt8](baseData)
    
//    if let json = try? JSONSerialization.jsonObject(with: baseData, options: []) as? [String:Any] {
//      iPrint(json)
//    }
    XCTAssertEqual(Infra_DID_Swift().text, "Hello, World!")
  }
}
