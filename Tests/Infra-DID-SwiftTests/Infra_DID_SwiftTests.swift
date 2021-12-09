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
//    let a = InfraDIDConstructor.createPubKeyDID(networkID: "01")
//    guard let did = a["did"], let pvKey = a["privateKey"], let netId = a["did"]?.split(separator: ":")[2]
//    else { return }
//
//    iPrint(pvKey)
    
    //test Data
    let idConfig: IdConfiguration = IdConfiguration(did: "did:infra:01:PUB_K1_7EKfvdZPzKX5jR7JTAreGnQguY7QnA9pdDbPqA4cNF9SQunuC3", didOwnerPrivateKey: "PVT_K1_5JYKUZKqumZmNmh35AcgrbtCHorFG2jcx5WsbkMjRRup9rXEwdx", networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io", jwtSigner: nil, txfeePayAccount: "qwexfhmvvdci", txfeePayerPrivateKey: "5KV84hXSJvu3nfqb9b1raRMnzvULaHH6Fsaz4xBZG2QbfPwMg76", pubKeyDidSignDataPrefix: nil)
    
    
    let didApi = InfraDIDConstructor(config: idConfig)
    didApi.setAttributePubKeyDID(action: .set, key: "svc/MessagingService", value: "https://infradid.com/pk/1/mysvcr9", newKey: "")
    //didApi.setAttributePubKeyDID(action: .clear)
    
    //"did:infra:sentinel:PUB_K1_7pM9qiBuHWF6WqRSjPTMfVYKV5ZFRavK4PkUq4oFhqi9Z46mWc"
    
    let infraDidResolver = await getResolver(options: MultiNetworkConfiguration(networks: [NetworkConfiguration(networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io")], noRevocationCheck: false))
    
    let didResolver = Resolver(registry: ResolverRegistry(methodName: infraDidResolver), options: ResolverOptions(cache: ResolverOptionsType.bool(true), legacyResolver: nil))
    
 //   guard let baseData = base64urlDecodedData(base64urlEncoded: "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NksifQ.eyJpYXQiOjE0ODUzMjExMzMsImRpZCI6ImRpZDpldGhyOjB4ZjNiZWFjMzBjNDk4ZDllMjY4NjVmMzRmY2FhNTdkYmI5MzViMGQ3NCIsImlzcyI6Imh0dHBzOi8vc2VsZi1pc3N1ZWQubWUifQ.2osZdSAqh8do2opJ-1RMXlDm8axkDSLhPS-bpeb4cOOtUEnF0i5fdZv7TC_aG2if-YmKlvRFMqrX5VaBBlrBXA") else { return }
    //let jwtString = try! baseData.toJsonString()
 //   iPrint(jwtString)
    //iPrint(decodeJwt(jwt: "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NksifQ.eyJ2YyI6eyJjcmVkZW50aWFsU3ViamVjdCI6eyJjbGFpbTEiOiJjbGFpbTFfdmFsdWUiLCJjbGFpbTIiOiJjbGFpbTJfdmFsdWUifSwiQGNvbnRleHQiOlsiaHR0cHM6Ly93d3cudzMub3JnLzIwMTgvY3JlZGVudGlhbHMvdjEiXSwidHlwZSI6WyJWZXJpZmlhYmxlQ3JlZGVudGlhbCIsIlZhY2NpbmF0aW9uQ3JlZGVudGlhbCJdfSwic3ViIjoiZGlkOmluZnJhOjAxOlBVQl9LMV83akNEYXJYblozU2RQQXdmRkVjaVRTeVV6QTRmbmZua3R2Rkg5Rmo3Sjg5VXJGaUhwdCIsImp0aSI6Imh0dHA6Ly9leGFtcGxlLnZjL2NyZWRlbnRpYWxzLzEyMzUzMiIsIm5iZiI6MTYxNzM1ODMwMSwiaXNzIjoiZGlkOmluZnJhOjAxOlBVQl9LMV84UHdHN29mNUI4cDlNcGF3Nlh6ZXlZdFNXSnllU1hWdHhaaFBIUUM1ZVp4WkNrcWlMVSJ9.ZByKShPxhKt2wlYsZQe6aGfxgjHuB1WW9X52cZjltMDLZEHJASXm7bsP5GwFG2dJtITYQ78NYgLXtLpRfLyxQQ"))


    
    //let payload = PresentationPayload(context: ["https://www.w3.org/2018/credentials/v1"], type: ["VerifiablePresentation"], verifiableCredential: VerifiableCredentialType.string(["eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NksifQ.eyJ2YyI6eyJjcmVkZW50aWFsU3ViamVjdCI6eyJjbGFpbTEiOiJjbGFpbTFfdmFsdWUiLCJjbGFpbTIiOiJjbGFpbTJfdmFsdWUifSwiQGNvbnRleHQiOlsiaHR0cHM6Ly93d3cudzMub3JnLzIwMTgvY3JlZGVudGlhbHMvdjEiXSwidHlwZSI6WyJWZXJpZmlhYmxlQ3JlZGVudGlhbCIsIlZhY2NpbmF0aW9uQ3JlZGVudGlhbCJdfSwic3ViIjoiZGlkOmluZnJhOjAxOlBVQl9LMV83akNEYXJYblozU2RQQXdmRkVjaVRTeVV6QTRmbmZua3R2Rkg5Rmo3Sjg5VXJGaUhwdCIsImp0aSI6Imh0dHA6Ly9leGFtcGxlLnZjL2NyZWRlbnRpYWxzLzEyMzUzMiIsIm5iZiI6MTYxNTk4NzExNywiaXNzIjoiZGlkOmluZnJhOjAxOlBVQl9LMV84UHdHN29mNUI4cDlNcGF3Nlh6ZXlZdFNXSnllU1hWdHhaaFBIUUM1ZVp4WkNrcWlMVSJ9.tGSAsEbF4bKb5bEWNtU1nItaMTYraSstaD2cxSfk9K13KZDOU07O3c6-2u9QKWpxHAm0ZhDGq9QQ07XDeGoqmw"]), holder: did, id: nil, verifier: ["did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz"], issuanceDate: formatter.string(from: Date.now), expirationDate: formatter.string(from: Date(timeIntervalSinceNow: (Double(Date.now.timeIntervalSinceNow) + 10*60*1000))))
    
    
    //iPrint(formatter.string(from: Date(timeIntervalSinceNow: (Double(Date.now.timeIntervalSinceNow) + 10*60*1000))))
    //iPrint(createVerifiablePresentationJwt(payload: payload, holder: holder).value)
    

   // let result = await createVerifiablePresentationJwt(payload: payload, holder: holder)
   // iPrint(result)
    
   // create Success
    
    
   //let results = await verifyPresentation(presentation: result, resolver: didResolver, options: VerifyPresentationOptions(audience: "did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz"))
    
   // iPrint(results)

    XCTAssertEqual(Infra_DID_Swift().text, "Hello, World!")
  }
  
  func testIdConfiguration() async throws {
    let idConfig: IdConfiguration = IdConfiguration(did: "did:infra:01:PUB_K1_7EKfvdZPzKX5jR7JTAreGnQguY7QnA9pdDbPqA4cNF9SQunuC3", didOwnerPrivateKey: "PVT_K1_5JYKUZKqumZmNmh35AcgrbtCHorFG2jcx5WsbkMjRRup9rXEwdx", networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io", jwtSigner: nil, txfeePayAccount: "qwexfhmvvdci", txfeePayerPrivateKey: "5KV84hXSJvu3nfqb9b1raRMnzvULaHH6Fsaz4xBZG2QbfPwMg76", pubKeyDidSignDataPrefix: nil)
    
    
    let didApi = InfraDIDConstructor(config: idConfig)
    didApi.setAttributePubKeyDID(action: .set, key: "svc/MessagingService", value: "https://infradid.com/pk/1/mysvcr9", newKey: "")
    XCTAssertEqual(Infra_DID_Swift().text, "Hello, World!")
  }
  
  
  func testVerifyJwt() async throws{
    let did = "did:infra:01:PUB_K1_7EKfvdZPzKX5jR7JTAreGnQguY7QnA9pdDbPqA4cNF9SQunuC3"
    let idConfig: IdConfiguration = IdConfiguration(did: did, didOwnerPrivateKey: "PVT_K1_5JYKUZKqumZmNmh35AcgrbtCHorFG2jcx5WsbkMjRRup9rXEwdx", networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io", jwtSigner: nil, txfeePayAccount: "qwexfhmvvdci", txfeePayerPrivateKey: "5KV84hXSJvu3nfqb9b1raRMnzvULaHH6Fsaz4xBZG2QbfPwMg76", pubKeyDidSignDataPrefix: nil)
    
    
    let didApi = InfraDIDConstructor(config: idConfig)
    let formatter = ISO8601DateFormatter.init()
    let holder = didApi.getJWTIssuer()
    
    let infraDidResolver = getResolver(options: MultiNetworkConfiguration(networks: [NetworkConfiguration(networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io")], noRevocationCheck: false))
    
    let didResolver = Resolver(registry: ResolverRegistry(methodName: infraDidResolver), options: ResolverOptions(cache: ResolverOptionsType.bool(true), legacyResolver: nil))
    
    let payload = PresentationPayload(context: ["https://www.w3.org/2018/credentials/v1"], type: ["VerifiablePresentation"], verifiableCredential: VerifiableCredentialType.string(["eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NksifQ.eyJ2YyI6eyJjcmVkZW50aWFsU3ViamVjdCI6eyJjbGFpbTEiOiJjbGFpbTFfdmFsdWUiLCJjbGFpbTIiOiJjbGFpbTJfdmFsdWUifSwiQGNvbnRleHQiOlsiaHR0cHM6Ly93d3cudzMub3JnLzIwMTgvY3JlZGVudGlhbHMvdjEiXSwidHlwZSI6WyJWZXJpZmlhYmxlQ3JlZGVudGlhbCIsIlZhY2NpbmF0aW9uQ3JlZGVudGlhbCJdfSwic3ViIjoiZGlkOmluZnJhOjAxOlBVQl9LMV83akNEYXJYblozU2RQQXdmRkVjaVRTeVV6QTRmbmZua3R2Rkg5Rmo3Sjg5VXJGaUhwdCIsImp0aSI6Imh0dHA6Ly9leGFtcGxlLnZjL2NyZWRlbnRpYWxzLzEyMzUzMiIsIm5iZiI6MTYxNTk4NzExNywiaXNzIjoiZGlkOmluZnJhOjAxOlBVQl9LMV84UHdHN29mNUI4cDlNcGF3Nlh6ZXlZdFNXSnllU1hWdHhaaFBIUUM1ZVp4WkNrcWlMVSJ9.tGSAsEbF4bKb5bEWNtU1nItaMTYraSstaD2cxSfk9K13KZDOU07O3c6-2u9QKWpxHAm0ZhDGq9QQ07XDeGoqmw"]), holder: did, id: nil, verifier: ["did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz"], issuanceDate: formatter.string(from: Date.now), expirationDate: formatter.string(from: Date(timeIntervalSince1970: (Double(Date.now.timeIntervalSince1970) + 10*60*1000))))
//    
    //let result = await createVerifiablePresentationJwt(payload: payload, holder: holder)
    
    //iPrint(result)
    let results = await verifyPresentation(presentation: "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NksifQ.eyJyZXF1ZXN0ZWQiOltdLCJpYXQiOjE2MzkwMzE0NTQuODk3Nzg0OSwibmJmIjoxNjM5MDMxNDUzLCJleHAiOjE2MzkwMzIwNTMsImF1ZCI6WyJkaWQ6aW5mcmE6MDE6UFVCX0sxXzVUYUVncFZ1cjM5MWRpbVZuRkNESEIxMjJEWFlCYndXZEtVcEVKQ052M2tvMUtNWXd6Il0sInZwIjp7ImNvbnRleHQiOlsiaHR0cHM6XC9cL3d3dy53My5vcmdcLzIwMThcL2NyZWRlbnRpYWxzXC92MSJdLCJ0eXBlIjpbIlZlcmlmaWFibGVQcmVzZW50YXRpb24iXSwidmVyaWZpYWJsZUNyZWRlbnRpYWwiOlsiZXlKMGVYQWlPaUpLVjFRaUxDSmhiR2NpT2lKRlV6STFOa3NpZlEuZXlKMll5STZleUpqY21Wa1pXNTBhV0ZzVTNWaWFtVmpkQ0k2ZXlKamJHRnBiVEVpT2lKamJHRnBiVEZmZG1Gc2RXVWlMQ0pqYkdGcGJUSWlPaUpqYkdGcGJUSmZkbUZzZFdVaWZTd2lRR052Ym5SbGVIUWlPbHNpYUhSMGNITTZMeTkzZDNjdWR6TXViM0puTHpJd01UZ3ZZM0psWkdWdWRHbGhiSE12ZGpFaVhTd2lkSGx3WlNJNld5SldaWEpwWm1saFlteGxRM0psWkdWdWRHbGhiQ0lzSWxaaFkyTnBibUYwYVc5dVEzSmxaR1Z1ZEdsaGJDSmRmU3dpYzNWaUlqb2laR2xrT21sdVpuSmhPakF4T2xCVlFsOUxNVjgzYWtORVlYSllibG96VTJSUVFYZG1Sa1ZqYVZSVGVWVjZRVFJtYm1adWEzUjJSa2c1Um1vM1NqZzVWWEpHYVVod2RDSXNJbXAwYVNJNkltaDBkSEE2THk5bGVHRnRjR3hsTG5aakwyTnlaV1JsYm5ScFlXeHpMekV5TXpVek1pSXNJbTVpWmlJNk1UWXhOVGs0TnpFeE55d2lhWE56SWpvaVpHbGtPbWx1Wm5KaE9qQXhPbEJWUWw5TE1WODRVSGRITjI5bU5VSTRjRGxOY0dGM05saDZaWGxaZEZOWFNubGxVMWhXZEhoYWFGQklVVU0xWlZwNFdrTnJjV2xNVlNKOS50R1NBc0ViRjRiS2I1YkVXTnRVMW5JdGFNVFlyYVNzdGFEMmN4U2ZrOUsxM0taRE9VMDdPM2M2LTJ1OVFLV3B4SEFtMFpoREdxOVFRMDdYRGVHb3FtdyJdfSwiaXNzIjoiZGlkOmluZnJhOjAxOlBVQl9LMV83RUtmdmRaUHpLWDVqUjdKVEFyZUduUWd1WTdRbkE5cGREYlBxQTRjTkY5U1F1bnVDMyJ9.dx2BvvJLBncOYjaLgqoixfBoSku4CX7Ag6EFakMhNsP2NeCwq6pyAErsbotKcsHyaSANAmyuBZALtdC-7kLCIw", resolver: didResolver, options: VerifyPresentationOptions(audience: "did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz"))
    
    iPrint(results)
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    
//    guard let jsonData = try? encoder.encode(results),
//
//      let object = try? JSONSerialization.data(withJSONObject: results, options: .prettyPrinted),
//          let jsonString = String(data: object, encoding: .utf8) else { return }
//    iPrint(jsonString)
    
    
  }
}
