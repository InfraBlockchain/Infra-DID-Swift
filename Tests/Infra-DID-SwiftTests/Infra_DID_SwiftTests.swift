import XCTest
@testable import Infra_DID_Swift
import PromiseKit
import Foundation
import CryptoKit
import secp256k1


final class Infra_DID_SwiftTests: XCTestCase {
  

  
  func testCreateDID() async throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    
    let did = InfraDIDConstructor.createPubKeyDID(networkID: "01")

    iPrint(did)
  }
  
  func testIdConfiguration() async throws {
    let idConfig: IdConfiguration = IdConfiguration(did: "did:infra:01:PUB_K1_7EKfvdZPzKX5jR7JTAreGnQguY7QnA9pdDbPqA4cNF9SQunuC3", didOwnerPrivateKey: "PVT_K1_5JYKUZKqumZmNmh35AcgrbtCHorFG2jcx5WsbkMjRRup9rXEwdx", networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io", jwtSigner: nil, txfeePayAccount: "qwexfhmvvdci", txfeePayerPrivateKey: "5KV84hXSJvu3nfqb9b1raRMnzvULaHH6Fsaz4xBZG2QbfPwMg76", pubKeyDidSignDataPrefix: nil)
    
    
    let didApi = InfraDIDConstructor(config: idConfig)
    didApi.actionPubKeyDID(actionName: .set, key: "svc/MessagingService", value: "https://infradid.com/pk/1/mysvcr9", newKey: "")
  }
  
  
  func testCreateVP() async throws {
    
    let a = InfraDIDConstructor.createPubKeyDID(networkID: "01")
    guard let did = a["did"], let pvKey = a["privateKey"], let netId = a["did"]?.split(separator: ":")[2]
    else { return }
    
    let idConfig: IdConfiguration = IdConfiguration(did: did, didOwnerPrivateKey: pvKey, networkId: String(netId), registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io", jwtSigner: nil, txfeePayAccount: "qwexfhmvvdci", txfeePayerPrivateKey: "5KV84hXSJvu3nfqb9b1raRMnzvULaHH6Fsaz4xBZG2QbfPwMg76", pubKeyDidSignDataPrefix: nil)
    
    let didApi = InfraDIDConstructor(config: idConfig)
    let formatter = ISO8601DateFormatter.init()
    let holder = didApi.getJWTIssuer()
    
    let payload = PresentationPayload(context: ["https://www.w3.org/2018/credentials/v1"], type: ["VerifiablePresentation"], verifiableCredential: VerifiableCredentialType.string(["eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJ2YyI6eyJpZCI6ImRpZDppbmZyYTowMTpQVUJfSzFfNWt6TVA0ZVYzRDRRU0tLNWhoWWpYWW53aVJBVjVzaGsyam5oclFCWnFUQndHUzZ5VTciLCJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vY29vdi5pby9kb2NzL3YxL3ZjL3BlcnNvbmFsIl0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJQZXJzb25hbCJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJuYW1lIjoi6rmA7KSA7ZiVIn19LCJzdWIiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZEOUhXaXFTcXVxdE1tVlU4UHJpdUQ1NjJQeEE0Y2ZNM251N1RtVUU5VVg5ODRmam9zIiwibmJmIjoxNjI3NTM3MjAyLCJpc3MiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZXR3J2bnVHN3hGeENGQTRkUHJlZmg5M0hVZEc3ZDFmalVRTnNaWFE2SmZSQzZHM1pDIn0.vOS-JvMZOQAxsnd8-IeIuwGtK5q0QEHEFxF2hUuLpBIE24M8TQZgp3E0Hgniy2bI6_ZfIa5jlG3_9r_ce-Fryw"]), holder: did, id: nil, verifier: ["did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz"], issuanceDate: formatter.string(from: Date.now), expirationDate: formatter.string(from: Date(timeIntervalSince1970: (Double(Date.now.timeIntervalSince1970) + 10*60*1000))))

    let result = await createVerifiablePresentationJwt(payload: payload, holder: holder)
    
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
      
      // case 2: one more VC In Vp
    let results = await verifyPresentation(presentation: result, resolver: didResolver, options: PresentationOptions(audience: "did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz", vcValidateFlag: true))

  }
  
  func testVerifyVcJwt() async throws {
    
    let infraDidResolver = getResolver(options: MultiNetworkConfiguration(networks: [NetworkConfiguration(networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io")], noRevocationCheck: false))
    
    let didResolver = Resolver(registry: ResolverRegistry(methodName: infraDidResolver), options: ResolverOptions(cache: ResolverOptionsType.bool(true), legacyResolver: nil))
    
    // make signature 64 bytes no HeaderByte
    let results1 = verifyCredential(credential: "eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJ2YyI6eyJpZCI6ImRpZDppbmZyYTowMTpQVUJfSzFfNWt6TVA0ZVYzRDRRU0tLNWhoWWpYWW53aVJBVjVzaGsyam5oclFCWnFUQndHUzZ5VTciLCJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vY29vdi5pby9kb2NzL3YxL3ZjL3BlcnNvbmFsIl0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJQZXJzb25hbCJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJuYW1lIjoi6rmA7KSA7ZiVIn19LCJzdWIiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZEOUhXaXFTcXVxdE1tVlU4UHJpdUQ1NjJQeEE0Y2ZNM251N1RtVUU5VVg5ODRmam9zIiwibmJmIjoxNjI3NTM3MjAyLCJpc3MiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZXR3J2bnVHN3hGeENGQTRkUHJlZmg5M0hVZEc3ZDFmalVRTnNaWFE2SmZSQzZHM1pDIn0.vOS-JvMZOQAxsnd8-IeIuwGtK5q0QEHEFxF2hUuLpBIE24M8TQZgp3E0Hgniy2bI6_ZfIa5jlG3_9r_ce-Fryw", resolver: didResolver)
    iPrint(results1)
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

