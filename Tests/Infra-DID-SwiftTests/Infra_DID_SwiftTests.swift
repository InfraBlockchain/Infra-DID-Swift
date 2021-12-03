import XCTest
@testable import Infra_DID_Swift
import PromiseKit
import Foundation

@available(macOS 12, *)
final class Infra_DID_SwiftTests: XCTestCase {
  
  func testExample() async throws {
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
    //iPrint(decodeJwt(jwt: "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NksifQ.eyJ2YyI6eyJjcmVkZW50aWFsU3ViamVjdCI6eyJjbGFpbTEiOiJjbGFpbTFfdmFsdWUiLCJjbGFpbTIiOiJjbGFpbTJfdmFsdWUifSwiQGNvbnRleHQiOlsiaHR0cHM6Ly93d3cudzMub3JnLzIwMTgvY3JlZGVudGlhbHMvdjEiXSwidHlwZSI6WyJWZXJpZmlhYmxlQ3JlZGVudGlhbCIsIlZhY2NpbmF0aW9uQ3JlZGVudGlhbCJdfSwic3ViIjoiZGlkOmluZnJhOjAxOlBVQl9LMV83akNEYXJYblozU2RQQXdmRkVjaVRTeVV6QTRmbmZua3R2Rkg5Rmo3Sjg5VXJGaUhwdCIsImp0aSI6Imh0dHA6Ly9leGFtcGxlLnZjL2NyZWRlbnRpYWxzLzEyMzUzMiIsIm5iZiI6MTYxNzM1ODMwMSwiaXNzIjoiZGlkOmluZnJhOjAxOlBVQl9LMV84UHdHN29mNUI4cDlNcGF3Nlh6ZXlZdFNXSnllU1hWdHhaaFBIUUM1ZVp4WkNrcWlMVSJ9.ZByKShPxhKt2wlYsZQe6aGfxgjHuB1WW9X52cZjltMDLZEHJASXm7bsP5GwFG2dJtITYQ78NYgLXtLpRfLyxQQ"))

    let formatter = ISO8601DateFormatter.init()
    let holder = didApi.getJWTIssuer()
    let payload = PresentationPayload(context: ["https://www.w3.org/2018/credentials/v1"], type: ["VerifiablePresentation"], id: nil, verifiableCredential: ["eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NksifQ.eyJ2YyI6eyJjcmVkZW50aWFsU3ViamVjdCI6eyJjbGFpbTEiOiJjbGFpbTFfdmFsdWUiLCJjbGFpbTIiOiJjbGFpbTJfdmFsdWUifSwiQGNvbnRleHQiOlsiaHR0cHM6Ly93d3cudzMub3JnLzIwMTgvY3JlZGVudGlhbHMvdjEiXSwidHlwZSI6WyJWZXJpZmlhYmxlQ3JlZGVudGlhbCIsIlZhY2NpbmF0aW9uQ3JlZGVudGlhbCJdfSwic3ViIjoiZGlkOmluZnJhOjAxOlBVQl9LMV83akNEYXJYblozU2RQQXdmRkVjaVRTeVV6QTRmbmZua3R2Rkg5Rmo3Sjg5VXJGaUhwdCIsImp0aSI6Imh0dHA6Ly9leGFtcGxlLnZjL2NyZWRlbnRpYWxzLzEyMzUzMiIsIm5iZiI6MTYxNTk4NzExNywiaXNzIjoiZGlkOmluZnJhOjAxOlBVQl9LMV84UHdHN29mNUI4cDlNcGF3Nlh6ZXlZdFNXSnllU1hWdHhaaFBIUUM1ZVp4WkNrcWlMVSJ9.tGSAsEbF4bKb5bEWNtU1nItaMTYraSstaD2cxSfk9K13KZDOU07O3c6-2u9QKWpxHAm0ZhDGq9QQ07XDeGoqmw"], holder: did, verifier: "did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz", issuanceDate: formatter.string(from: Date.now), expirationDate: formatter.string(from: Date(timeIntervalSinceNow: (Double(Date.now.timeIntervalSinceNow) + 10*60*1000))))
    iPrint(formatter.string(from: Date(timeIntervalSinceNow: (Double(Date.now.timeIntervalSinceNow) + 10*60*1000))))
    //iPrint(createVerifiablePresentationJwt(payload: payload, holder: holder).value)
    let result = await createVerifiablePresentationJwt(payload: payload, holder: holder)
    iPrint(result)
//    firstly {
//      createVerifiablePresentationJwt(payload: payload, holder: holder)
//    }.done { jwtString in
//      iPrint(jwtString)
//    }
    XCTAssertEqual(Infra_DID_Swift().text, "Hello, World!")
  }
}
