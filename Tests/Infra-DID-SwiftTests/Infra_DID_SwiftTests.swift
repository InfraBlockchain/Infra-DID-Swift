import XCTest
@testable import Infra_DID_Swift
import PromiseKit
import Foundation
import CryptoKit
import secp256k1


final class Infra_DID_SwiftTests: XCTestCase {
  

  
  func testExample() async throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    
    //1. DID 생성한다
    let a = InfraDIDConstructor.createPubKeyDID(networkID: "01")
//    guard let did = a["did"], let pvKey = a["privateKey"], let netId = a["did"]?.split(separator: ":")[2]0
//    else { return }
//
//    iPrint(pvKey)
    
    //test Data
    let idConfig: IdConfiguration = IdConfiguration(did: "did:infra:01:PUB_K1_7EKfvdZPzKX5jR7JTAreGnQguY7QnA9pdDbPqA4cNF9SQunuC3", didOwnerPrivateKey: "PVT_K1_5JYKUZKqumZmNmh35AcgrbtCHorFG2jcx5WsbkMjRRup9rXEwdx", networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io", jwtSigner: nil, txfeePayAccount: "qwexfhmvvdci", txfeePayerPrivateKey: "5KV84hXSJvu3nfqb9b1raRMnzvULaHH6Fsaz4xBZG2QbfPwMg76", pubKeyDidSignDataPrefix: nil)
    
    
    let didApi = InfraDIDConstructor(config: idConfig)
    didApi.actionPubKeyDID(action: .set, key: "svc/MessagingService", value: "https://infradid.com/pk/1/mysvcr9", newKey: "")
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
    didApi.actionPubKeyDID(action: .set, key: "svc/MessagingService", value: "https://infradid.com/pk/1/mysvcr9", newKey: "")
    XCTAssertEqual(Infra_DID_Swift().text, "Hello, World!")
  }
  
  
  func testVerifyVpJwt() async throws{
    let a = InfraDIDConstructor.createPubKeyDID(networkID: "01")
    guard let did = a["did"], let pvKey = a["privateKey"], let netId = a["did"]?.split(separator: ":")[2]
    else { return }


    let idConfig: IdConfiguration = IdConfiguration(did: did, didOwnerPrivateKey: pvKey, networkId: String(netId), registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io", jwtSigner: nil, txfeePayAccount: "qwexfhmvvdci", txfeePayerPrivateKey: "5KV84hXSJvu3nfqb9b1raRMnzvULaHH6Fsaz4xBZG2QbfPwMg76", pubKeyDidSignDataPrefix: nil)
    
    let didApi = InfraDIDConstructor(config: idConfig)
    let formatter = ISO8601DateFormatter.init()
    let holder = didApi.getJWTIssuer()
    
    let infraDidResolver = getResolver(options: MultiNetworkConfiguration(networks: [NetworkConfiguration(networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io")], noRevocationCheck: false))
    
    let didResolver = Resolver(registry: ResolverRegistry(methodName: infraDidResolver), options: ResolverOptions(cache: ResolverOptionsType.bool(true), legacyResolver: nil))
    
    //case 1: one more VC In VP
    let payload = PresentationPayload(context: ["https://www.w3.org/2018/credentials/v1"], type: ["VerifiablePresentation"], verifiableCredential: VerifiableCredentialType.string(["eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJ2YyI6eyJpZCI6ImRpZDppbmZyYTowMTpQVUJfSzFfNWt6TVA0ZVYzRDRRU0tLNWhoWWpYWW53aVJBVjVzaGsyam5oclFCWnFUQndHUzZ5VTciLCJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vY29vdi5pby9kb2NzL3YxL3ZjL3BlcnNvbmFsIl0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJQZXJzb25hbCJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJuYW1lIjoi6rmA7KSA7ZiVIn19LCJzdWIiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZEOUhXaXFTcXVxdE1tVlU4UHJpdUQ1NjJQeEE0Y2ZNM251N1RtVUU5VVg5ODRmam9zIiwibmJmIjoxNjI3NTM3MjAyLCJpc3MiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZXR3J2bnVHN3hGeENGQTRkUHJlZmg5M0hVZEc3ZDFmalVRTnNaWFE2SmZSQzZHM1pDIn0.vOS-JvMZOQAxsnd8-IeIuwGtK5q0QEHEFxF2hUuLpBIE24M8TQZgp3E0Hgniy2bI6_ZfIa5jlG3_9r_ce-Fryw"]), holder: did, id: nil, verifier: ["did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz"], issuanceDate: formatter.string(from: Date.now), expirationDate: formatter.string(from: Date(timeIntervalSince1970: (Double(Date.now.timeIntervalSince1970) + 10*60*1000))))

    let result = await createVerifiablePresentationJwt(payload: payload, holder: holder)
    
    //iPrint(result)
    //iPrint(result)
      // case 1 : just One VC In VP
   // let results = await verifyPresentation(presentation: "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NksifQ.eyJ2cCI6eyJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSJdLCJ0eXBlIjpbIlZlcmlmaWFibGVQcmVzZW50YXRpb24iXSwidmVyaWZpYWJsZUNyZWRlbnRpYWwiOlsiZXlKaGJHY2lPaUpGVXpJMU5rc2lMQ0owZVhBaU9pSktWMVFpZlEuZXlKbGVIQWlPakU1TWpRek5UUTRNREFzSW5aaklqcDdJbWxrSWpvaVpHbGtPbWx1Wm5KaE9qQXhPbEJWUWw5TE1WODFkMWQwYXpoVVZ6WnlWazFuV0V0UWFFcHRlRmRFTTJKNVlXRnJZazF2UldsaVV6TTFXVkJ5YXpNM2RXdG1kV2cxUkNJc0lrQmpiMjUwWlhoMElqcGJJbWgwZEhCek9pOHZkM2QzTG5jekxtOXlaeTh5TURFNEwyTnlaV1JsYm5ScFlXeHpMM1l4SWl3aWFIUjBjSE02THk5amIyOTJMbWx2TDJSdlkzTXZkbU12Y0dGemMzQnZjblFpWFN3aWRIbHdaU0k2V3lKV1pYSnBabWxoWW14bFEzSmxaR1Z1ZEdsaGJDSXNJbEJoYzNOd2IzSjBJbDBzSW1OeVpXUmxiblJwWVd4VGRXSnFaV04wSWpwN0ltWnVJam9pUzBsTklpd2laMjRpT2lKQ1JVOU5VMFZQSWl3aWNIQnVJam9pVFRBMU9USTVNemcwSW4xOUxDSnpkV0lpT2lKa2FXUTZhVzVtY21FNk1ERTZVRlZDWDBzeFh6VjRSMlYwTWxVM01VMXZjVU5XYWpaM2FqZFdTakpDYm1Wdk0zVm1jRkpaV2tKQmIwVnFNWEZEUTNCQlJrUnpTa1kxSWl3aWRtVnlJam9pTUM0NUlpd2lhWE56SWpvaVpHbGtPbWx1Wm5KaE9qQXhPbEJWUWw5TE1WODNhVTE0VWt4R1lYWTVkMDVxZW1SQmVYSnpVM04zUTI1eWVISlJkVGx1Y1U1M09UbElaelE1U0VKRU9ERkJabnBVTXlKOS5EcVFLaUpZYkFwVzlSM292TFdaYTB6RU02bzFMd0VjRTBnbjktNjRwVmpycFdBZ1QzQU9iTXBhQ3FHaTNRaEkxM3pBSWY2YmNfS1Jwbk56blQzejBndyIsImV5SmhiR2NpT2lKRlV6STFOa3NpTENKMGVYQWlPaUpLVjFRaWZRLmV5SjJZeUk2ZXlKcFpDSTZJbVJwWkRwcGJtWnlZVG93TVRwUVZVSmZTekZmTlhCNWRYTlhVbWM1ZVVoUlZEazJjVXhCYWtGWE5sbFRaRkp0UkV4U1MyUnRaMFZwVUhsWVZuRTVTR1JCWTFsWVNrMGlMQ0pBWTI5dWRHVjRkQ0k2V3lKb2RIUndjem92TDNkM2R5NTNNeTV2Y21jdk1qQXhPQzlqY21Wa1pXNTBhV0ZzY3k5Mk1TSXNJbWgwZEhCek9pOHZZMjl2ZGk1cGJ5OWtiMk56TDNaakwzQmxjbk52Ym1Gc0lsMHNJblI1Y0dVaU9sc2lWbVZ5YVdacFlXSnNaVU55WldSbGJuUnBZV3dpTENKUVpYSnpiMjVoYkNKZExDSmpjbVZrWlc1MGFXRnNVM1ZpYW1WamRDSTZleUprYjJJaU9pSXhPVGt5TURVeE9TSjlmU3dpYzNWaUlqb2laR2xrT21sdVpuSmhPakF4T2xCVlFsOUxNVjgxZUVkbGRESlZOekZOYjNGRFZtbzJkMm8zVmtveVFtNWxiek4xWm5CU1dWcENRVzlGYWpGeFEwTndRVVpFYzBwR05TSXNJblpsY2lJNklqQXVPU0lzSW1semN5STZJbVJwWkRwcGJtWnlZVG93TVRwUVZVSmZTekZmTjJsTmVGSk1SbUYyT1hkT2FucGtRWGx5YzFOemQwTnVjbmh5VVhVNWJuRk9kems1U0djME9VaENSRGd4UVdaNlZETWlmUS42dENJbC1iNzJTaldQYmc1YVhrbmZsWHJqY2lBemplVENhcnNBeWRUNUN2aDZDaW9Gd1hZa3lITU0xR3JkNGZUSkh6bGVCR3RGbHlFaDZxQjIzMURvQSIsImV5SmhiR2NpT2lKRlV6STFOa3NpTENKMGVYQWlPaUpLVjFRaWZRLmV5SjJZeUk2ZXlKcFpDSTZJbVJwWkRwcGJtWnlZVG93TVRwUVZVSmZTekZmTjBKWU5ERnBORTFaUVd0V2NVNUJUalpDTm1oaGVFeGhWMjFWVXpOU01WSnpiMU51TjI5TU9YVkVSVmN4TnpWamJtSWlMQ0pBWTI5dWRHVjRkQ0k2V3lKb2RIUndjem92TDNkM2R5NTNNeTV2Y21jdk1qQXhPQzlqY21Wa1pXNTBhV0ZzY3k5Mk1TSmRMQ0owZVhCbElqcGJJbFpsY21sbWFXRmliR1ZEY21Wa1pXNTBhV0ZzSWl3aVEyVnlkR2xtYVdOaGRHVWlYU3dpWTNKbFpHVnVkR2xoYkZOMVltcGxZM1FpT25zaWRtRmpZMmx1WlNJNklrTlBWa2xFTVRraUxDSmljbUZ1WkNJNklrcGhibk56Wlc0aUxDSnNiM1JPZFcwaU9pSkJRa05FTVRJek5DSXNJbVJ2YzJWT2RXMGlPakVzSW1SaGRHVWlPaUl5TURJeE1EZ3dNU0lzSW1OdmRXNTBjbmtpT2lKTFVpSXNJbUZrYldsdVEyVnVkSEpsSWpvaTZyV3Q2NmE5N0tTUjdKV1o3SjJZNjZPTTdKdVFJaXdpYVdRaU9qSXhNREFzSW1Ga2JXbHVRMlZ1ZEhKbFNXUWlPaUpqYnpFME1tWWlMQ0poWkcxcGJrTmxiblJ5WlVWdVp5STZJazVoZEdsdmJtRnNJRTFsWkdsallXd2dRMlZ1ZEdWeUluMTlMQ0p6ZFdJaU9pSmthV1E2YVc1bWNtRTZNREU2VUZWQ1gwc3hYelY0UjJWME1sVTNNVTF2Y1VOV2FqWjNhamRXU2pKQ2JtVnZNM1ZtY0ZKWldrSkJiMFZxTVhGRFEzQkJSa1J6U2tZMUlpd2lkbVZ5SWpvaU1DNDVJaXdpYVhOeklqb2laR2xrT21sdVpuSmhPakF4T2xCVlFsOUxNVjgzYVUxNFVreEdZWFk1ZDA1cWVtUkJlWEp6VTNOM1EyNXllSEpSZFRsdWNVNTNPVGxJWnpRNVNFSkVPREZCWm5wVU15SjkubkRxQk5yOFRybXBMTVlLeHpGQ3BBRG5uUVh4R0w2YWluT3JNMzhIZkFGX0dnRWhEaGNqT2g4bVBJZWxBb3hVY1cxWDZFTlNrc0RDYjh2T0Juc0lxd2ciXX0sIm5iZiI6MTYzOTM2MTgxNiwiaXNzIjoiZGlkOmluZnJhOjAxOlBVQl9LMV81eEdldDJVNzFNb3FDVmo2d2o3VkoyQm5lbzN1ZnBSWVpCQW9FajFxQ0NwQUZEc0pGNSIsImF1ZCI6WyJkaWQ6aW5mcmE6MDE6UFVCX0sxXzdpTXhSTEZhdjl3Tmp6ZEF5cnNTc3dDbnJ4clF1OW5xTnc5OUhnNDlIQkQ4MUFmelQzIl0sIm5vbmNlIjoiZGlkOmluZnJhOjAxOlBVQl9LMV83SnpYUjZGZVZxNGhBY0ZNZW5Cb2Vjb0hjZm9KZzg0R2VhRWtacmFUNkx6c1RmZFR3ZiJ9.1--b_20pIGJi0jLS1eFCfV8VKVwsoOy-FP56mhHfC8NQ9vjCSn6NtZHSAb50rafqXHPlrgwt1loNurNgKJSlXg", resolver: didResolver, options: PresentationOptions(audience: "did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz"))
      
      
      // case 2: one more VC In Vp
    let results = await verifyPresentation(presentation: result, resolver: didResolver, options: PresentationOptions(audience: "did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz", vcValidateFlag: true))
//
   //iPrint(results)
//    let encoder = JSONEncoder()
//    encoder.dateEncodingStrategy = .iso8601
    
//    guard let jsonData = try? encoder.encode(results),
//
//      let object = try? JSONSerialization.data(withJSONObject: results, options: .prettyPrinted),
//          let jsonString = String(data: object, encoding: .utf8) else { return }
//    iPrint(jsonString)
    
    
  }
  
  func testVerifyVcJwt() async throws {
//    let did = "did:infra:01:PUB_K1_8PwG7of5B8p9Mpaw6XzeyYtSWJyeSXVtxZhPHQC5eZxZCkqiLU"
//    let idConfig: IdConfiguration = IdConfiguration(did: did, didOwnerPrivateKey: "PVT_K1_5JYKUZKqumZmNmh35AcgrbtCHorFG2jcx5WsbkMjRRup9rXEwdx", networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io", jwtSigner: nil, txfeePayAccount: "qwexfhmvvdci", txfeePayerPrivateKey: "5KV84hXSJvu3nfqb9b1raRMnzvULaHH6Fsaz4xBZG2QbfPwMg76", pubKeyDidSignDataPrefix: nil)
//
//    let didApi = InfraDIDConstructor(config: idConfig)
//    let formatter = ISO8601DateFormatter.init()
//    let holder = didApi.getJWTIssuer()
    
    let infraDidResolver = getResolver(options: MultiNetworkConfiguration(networks: [NetworkConfiguration(networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io")], noRevocationCheck: false))
    
    let didResolver = Resolver(registry: ResolverRegistry(methodName: infraDidResolver), options: ResolverOptions(cache: ResolverOptionsType.bool(true), legacyResolver: nil))
    
    
    // make signature 65 bytes
   // let results = await verifyCredential(credential: "eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJuYmYiOjE2Mzk2MzUzNjYsInZjIjp7IkBjb250ZXh0IjpbImh0dHBzOlwvXC93d3cudzMub3JnXC8yMDE4XC9jcmVkZW50aWFsc1wvdjEiXSwidHlwZSI6WyJWZXJpZmlhYmxlQ3JlZGVudGlhbCIsIlZhY2NpbmF0aW9uQ3JlZGVudGlhbCJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJpZCI6ImRpZDppbmZyYTowMTpQVUJfSzFfN2pDRGFyWG5aM1NkUEF3ZkZFY2lUU3lVekE0Zm5mbmt0dkZIOUZqN0o4OVVyRmlIcHQiLCJjbGFpbTEiOiJjbGFpbTFWYWx1ZSJ9fSwiaXNzIjoiZGlkOmluZnJhOjAxOlBVQl9LMV81UGFXeWdCVkh1bW44UlVQQ0h5aTJhSlpYeU5SaEJ2Qk5HUk5xZFJLY0djeFVhQlEzYSIsInN1YiI6ImRpZDppbmZyYTowMTpQVUJfSzFfN2pDRGFyWG5aM1NkUEF3ZkZFY2lUU3lVekE0Zm5mbmt0dkZIOUZqN0o4OVVyRmlIcHQiLCJpYXQiOjE2Mzk2MzUzNjguMTc1MjN9.H20A9VtIIKK4jv1wYoKPF65XSG09a7_26RUHLGpSfXvAR7piw36TZ2IfbpTOkb2LmuPTFesKLUTdUqQlUITM4FQ", resolver: didResolver)
    
    // make signature 64 bytes no HeaderByte
    let results1 = await verifyCredential(credential: "eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJ2YyI6eyJpZCI6ImRpZDppbmZyYTowMTpQVUJfSzFfNWt6TVA0ZVYzRDRRU0tLNWhoWWpYWW53aVJBVjVzaGsyam5oclFCWnFUQndHUzZ5VTciLCJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vY29vdi5pby9kb2NzL3YxL3ZjL3BlcnNvbmFsIl0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJQZXJzb25hbCJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJuYW1lIjoi6rmA7KSA7ZiVIn19LCJzdWIiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZEOUhXaXFTcXVxdE1tVlU4UHJpdUQ1NjJQeEE0Y2ZNM251N1RtVUU5VVg5ODRmam9zIiwibmJmIjoxNjI3NTM3MjAyLCJpc3MiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZXR3J2bnVHN3hGeENGQTRkUHJlZmg5M0hVZEc3ZDFmalVRTnNaWFE2SmZSQzZHM1pDIn0.vOS-JvMZOQAxsnd8-IeIuwGtK5q0QEHEFxF2hUuLpBIE24M8TQZgp3E0Hgniy2bI6_ZfIa5jlG3_9r_ce-Fryw", resolver: didResolver)
    
   // iPrint(results1)
  }
  
  
  func testKey() async throws {
    let key = try! Data(hexString: "03cdf359def0d227223b10fba97c3b786899c0cc33ffd6cc8d60ce709f489c4f47")
    //key?.toEosioK1PublicKey
    iPrint(key?.toEosioK1PublicKey)
  }
  
  func testCreateVC() async throws {
    let a = InfraDIDConstructor.createPubKeyDID(networkID: "01")
    guard let did = a["did"], let pvKey = a["privateKey"], let netId = a["did"]?.split(separator: ":")[2]
    else { return }
    
    
    //let keyPair = try! secp256k1.Signing.PrivateKey.init(rawRepresentation: try! Data(hex: "278a5de700e29faae8e40e366ec5012b5ec63d36ec77e8a2417154cc1d25383f"))
    //let did = "did:infra:01:\(keyPair.publicKey.rawRepresentation.toEosioK1PublicKey)"
    let idConfig: IdConfiguration = IdConfiguration(did: did, didOwnerPrivateKey: pvKey, networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io", jwtSigner: nil, txfeePayAccount: "qwexfhmvvdci", txfeePayerPrivateKey: "5KV84hXSJvu3nfqb9b1raRMnzvULaHH6Fsaz4xBZG2QbfPwMg76", pubKeyDidSignDataPrefix: nil)
    
    let didApi = InfraDIDConstructor(config: idConfig)
    let formatter = ISO8601DateFormatter.init()
    let issuer = didApi.getJWTIssuer()
    
    let payload = CredentialPayload(context: ["https://www.w3.org/2018/credentials/v1"], id: "http://example.vc/credentials/123532", type: ["VerifiableCredential", "VaccinationCredential"], issuer: ["id": "\(idConfig.did)"], issuanceDate: formatter.string(from: Date.now), expirationDate: nil, credentialSubject: ["id": "did:infra:01:PUB_K1_7jCDarXnZ3SdPAwfFEciTSyUzA4fnfnktvFH9Fj7J89UrFiHpt", "claim1": "claim1Value"], credentialStatus: CredentialStatus(), evidence: nil, termsOfUse: nil)
    
    let result = await createVerifiableCredentialJwt(payload: payload, issuer: issuer)
    iPrint(result)
  }
}

