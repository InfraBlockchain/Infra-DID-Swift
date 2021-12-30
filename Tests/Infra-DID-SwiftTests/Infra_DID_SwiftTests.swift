import XCTest
@testable import Infra_DID_Swift
import PromiseKit
import Foundation
import CryptoKit
import secp256k1
import EosioSwift


#if SWIFT_PACKAGE
import libtom
#endif

final class Infra_DID_SwiftTests: XCTestCase {
  

  
  func testCreateDID() async throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    
    let did = InfraDIDConstructor.createPubKeyDID(networkID: "01")
    
    iPrint(did)
    ["privateKey": "PVT_K1_5KSvrttdrp3GbTcCuwcx4Nr9H2qkKwjYfABnDFe3Q7PEj3BUe5B",
     "did": "did:infra:01:PUB_K1_6UY4G4ZBd27AssbniQ5513LkyVZnM2hYz2Rc7GUjjo8wDAja9r",
     "publicKey": "PUB_K1_6UY4G4ZBd27AssbniQ5513LkyVZnM2hYz2Rc7GUjjo8wDAja9r"]
  }
  
  func testIdConfiguration() async throws {
//    let a = InfraDIDConstructor.createPubKeyDID(networkID: "01")
//    guard let did = a["did"], let pvKey = a["privateKey"], let netId = a["did"]?.split(separator: ":")[2]
//    else { return }
    
    let idConfig: IdConfiguration =
    IdConfiguration(
      did: "did:infra:01:PUB_K1_6bHxkmnSJQCD1AA5cARqsXDGUWY5ScVxtkwdb71quQVJ5E1JTH",
      didOwnerPrivateKey:"PVT_K1_5K9H1nzqyBAmuuvWCyVgsFciVsiSike1L38WG6Y6LjcssBmNpvT", networkId: "01",
      registryContract: "fmapkumrotfc",
      rpcEndpoint: "https://api.testnet.eos.io",
      jwtSigner: nil,
      txfeePayAccount: "qwexfhmvvdci",
      txfeePayerPrivateKey:"5KV84hXSJvu3nfqb9b1raRMnzvULaHH6Fsaz4xBZG2QbfPwMg76", pubKeyDidSignDataPrefix: nil)
    
    
    let didApi = InfraDIDConstructor(config: idConfig)
    //didApi.actionPubKeyDID(actionName: .clear, key: "", value: "", newKey: "")
    didApi.actionPubKeyDID(actionName: .set, key: "svc/MessagingService", value: "https://infradid.com/pk/3/mysvcr90", newKey: "")
    didApi.actionPubKeyDID(actionName: .revoke)
    didApi.actionPubKeyDID(actionName: .clear)
    didApi.actionPubKeyDID(actionName: .changeOwner, key: "", value: "", newKey: "PUB_K1_584qGNgteYFppoisbDz6vBFArrw3As8qeeRCekLepG4pJVrhJt")
    didApi.actionPubKeyDID(actionName: .setAccount, key: "svc/MessagingService", value: "https://infradid.com/acc/1/mysvcr7", newKey: "")
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

    let vp = createVerifiablePresentationJwt(payload: payload, holder: holder)
      
      // case 2: one more VC In Vp
    let vpVerified = verifyPresentation(presentation: vp, resolver: didResolver, options: PresentationOptions(audience: "did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz", vcValidateFlag: true))
    guard let string = try? vpVerified.toJsonString(convertToSnakeCase: true, prettyPrinted: true) else { return }
    iPrint(string)
  }
  
  func testVerifyVcJwt() async throws {
    
    let infraDidResolver = getResolver(options: MultiNetworkConfiguration(networks: [NetworkConfiguration(networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io")], noRevocationCheck: false))
    
    let didResolver = Resolver(registry: ResolverRegistry(methodName: infraDidResolver), options: ResolverOptions(cache: ResolverOptionsType.bool(true), legacyResolver: nil))
    
    // make signature 64 bytes no HeaderByte
    let results1 = verifyCredential(credential: "eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJ2YyI6eyJpZCI6ImRpZDppbmZyYTowMTpQVUJfSzFfNWt6TVA0ZVYzRDRRU0tLNWhoWWpYWW53aVJBVjVzaGsyam5oclFCWnFUQndHUzZ5VTciLCJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vY29vdi5pby9kb2NzL3YxL3ZjL3BlcnNvbmFsIl0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJQZXJzb25hbCJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJuYW1lIjoi6rmA7KSA7ZiVIn19LCJzdWIiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZEOUhXaXFTcXVxdE1tVlU4UHJpdUQ1NjJQeEE0Y2ZNM251N1RtVUU5VVg5ODRmam9zIiwibmJmIjoxNjI3NTM3MjAyLCJpc3MiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZXR3J2bnVHN3hGeENGQTRkUHJlZmg5M0hVZEc3ZDFmalVRTnNaWFE2SmZSQzZHM1pDIn0.vOS-JvMZOQAxsnd8-IeIuwGtK5q0QEHEFxF2hUuLpBIE24M8TQZgp3E0Hgniy2bI6_ZfIa5jlG3_9r_ce-Fryw", resolver: didResolver)
    iPrint(results1)
    
    guard let string = try? results1.toJsonString(convertToSnakeCase: true, prettyPrinted: true) else { return }
    iPrint(string)
  }
  
  
  func testKey() async throws {
    //PUB_K1_6iM11zaxqGaPKboKMBFKMNAtAxPws3NttuJZYmsk1HAHTGtwh8

    
  }
  
  func testCreateVC() async throws {
    let a = InfraDIDConstructor.createPubKeyDID(networkID: "01")
    guard let did = a["did"], let pvKey = a["privateKey"], let netId = a["did"]?.split(separator: ":")[2]
    else { return }
    
    let idConfig: IdConfiguration = IdConfiguration(did: did, didOwnerPrivateKey: pvKey, networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io", jwtSigner: nil, txfeePayAccount: "qwexfhmvvdci", txfeePayerPrivateKey: "5KV84hXSJvu3nfqb9b1raRMnzvULaHH6Fsaz4xBZG2QbfPwMg76", pubKeyDidSignDataPrefix: nil)
    
    let infraDidResolver = getResolver(options: MultiNetworkConfiguration(networks: [NetworkConfiguration(networkId: "01", registryContract: "fmapkumrotfc", rpcEndpoint: "https://api.testnet.eos.io")], noRevocationCheck: false))
    
    let didResolver = Resolver(registry: ResolverRegistry(methodName: infraDidResolver), options: ResolverOptions(cache: ResolverOptionsType.bool(true), legacyResolver: nil))
    
    let didApi = InfraDIDConstructor(config: idConfig)
    let formatter = ISO8601DateFormatter.init()
    let issuer = didApi.getJWTIssuer()
    
    let payload = CredentialPayload(context: ["https://www.w3.org/2018/credentials/v1"],
                                    id: "http://example.vc/credentials/123532",
                                    type: ["VerifiableCredential", "VaccinationCredential"],
                                    issuer: ["id": "\(idConfig.did)"],
                                    issuanceDate: formatter.string(from: Date.now),
                                    expirationDate: nil,
                                    credentialSubject:
                                      SubjectValue.object(
                                        ["id":
               SubjectValue.string("did:infra:01:PUB_K1_7jCDarXnZ3SdPAwfFEciTSyUzA4fnfnktvFH9Fj7J89UrFiHpt"), "claim1": SubjectValue.string("claim1Value")]), credentialStatus: CredentialStatus(), evidence: nil, termsOfUse: nil)
    
    let vc = await createVerifiableCredentialJwt(payload: payload, issuer: issuer)
    
    let vcVerified = verifyCredential(credential: vc, resolver: didResolver)

    
    
    iPrint(vc)
    guard let string = try? vcVerified.toJsonString(convertToSnakeCase: true, prettyPrinted: true) else { return }
    iPrint(string)
  }
}

