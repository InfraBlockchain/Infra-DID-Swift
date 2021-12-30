# Infra DID Swift Library

<p align="left">
<img src="https://img.shields.io/badge/Swift-5.0-orange.svg" alt="">
</p>




* Infra DID Method Spec
  - https://github.com/InfraBlockchain/infra-did-method-specs/blob/main/docs/Infra-DID-method-spec.md

* Infra DID Registry Smart Contract on InfraBlockchain
  - https://github.com/InfraBlockchain/infra-did-registry

* Infra DID Resolver (DIF javascript universal resolver compatible)
  - https://github.com/InfraBlockchain/infra-did-resolver


Feature provided by Infra-DID-Swift Library :
  - Infra DID Creation
  - Update DID Attribute
  - DID Resolver
  - Create And Verify Verifiable Credential JWT
  - Create And Verify Verifiable Presentation JWT

### Infra DID API Configuration

```swift
   let idConfig: IdConfiguration =
    IdConfiguration(
      did: "did:infra:01:PUB_K1_6bHxkmnSJQCD1AA5cARqsXDGUWY5ScVxtkwdb71quQVJ5E1JTH",
      didOwnerPrivateKey:"PVT_K1_5K9H1nzqyBAmuuvWCyVgsFciVsiSike1L38WG6Y6LjcssBmNpvT", networkId: "01",
      registryContract: "infradidregi",
      rpcEndpoint: "https://api.testnet.infrablockchain.com",
      jwtSigner: nil,
      txfeePayAccount: "txfeepayeraa",
      txfeePayerPrivateKey:"TXFEE_PAYER_PRIVATE_KEY", pubKeyDidSignDataPrefix: nil)
    
    
    let didApi = InfraDIDConstructor(config: idConfig)
```

### Infra DID Creation 

currently secp256k1 curve is supported

```swift
   let did = InfraDIDConstructor.createPubKeyDID(networkID: "01")
   
   did result: ["privateKey": "PVT_K1_5KSvrttdrp3GbTcCuwcx4Nr9H2qkKwjYfABnDFe3Q7PEj3BUe5B",
                "did": "did:infra:01:PUB_K1_6UY4G4ZBd27AssbniQ5513LkyVZnM2hYz2Rc7GUjjo8wDAja9r",
                "publicKey": "PUB_K1_6UY4G4ZBd27AssbniQ5513LkyVZnM2hYz2Rc7GUjjo8wDAja9r"] 
```

### Update DID Attribute

Configuration Example
```swift
let idConfig: IdConfiguration =
    IdConfiguration(
      did: "did:infra:01:PUB_K1_6bHxkmnSJQCD1AA5cARqsXDGUWY5ScVxtkwdb71quQVJ5E1JTH",
      didOwnerPrivateKey:"PVT_K1_5K9H1nzqyBAmuuvWCyVgsFciVsiSike1L38WG6Y6LjcssBmNpvT", networkId: "01",
      registryContract: "infradidregi",
      rpcEndpoint: "https://api.testnet.infrablockchain.com",
      jwtSigner: nil,
      txfeePayAccount: "txfeepayeraa",
      txfeePayerPrivateKey:"TXFEE_PAYER_PRIVATE_KEY", pubKeyDidSignDataPrefix: nil)
```
      
Set Pub-Key DID Attribute
```swift
   let didApi = InfraDIDConstructor(config: idConfig)
   didApi.actionPubKeyDID(actionName: .set, key: "svc/MessagingService", value: "https://infradid.com/pk/3/mysvcr90", newKey: "")
```
Revoke Pub-Key DID Attribute
```swift
   let didApi = InfraDIDConstructor(config: idConfig)
   didApi.actionPubKeyDID(actionName: .revoke)
```

Clear Pub-Key DID Attribute
```swift
   let didApi = InfraDIDConstructor(config: idConfig)
   didApi.actionPubKeyDID(actionName: .clear)
```

Change Pub-Key DID Owner Key
```swift
   let didApi = InfraDIDConstructor(config: idConfig)
   didApi.actionPubKeyDID(actionName: .changeOwner, key: "", value: "", newKey: "PUB_K1_584qGNgteYFppoisbDz6vBFArrw3As8qeeRCekLepG4pJVrhJt")
```

Set Account-based DID Owner Key
```swift
   let idConfig: IdConfiguration =
    IdConfiguration(
      did: "did:infra:01:jghpykcpaoko",
      didOwnerPrivateKey:"PVT_K1_PRIVATE_KEY", networkId: "01",
      registryContract: "infradidregi",
      rpcEndpoint: "https://api.testnet.infrablockchain.com",
      jwtSigner: nil,
      txfeePayAccount: "txfeepayeraa",
      txfeePayerPrivateKey:"TXFEE_PAYER_PRIVATE_KEY", pubKeyDidSignDataPrefix: nil)

   let didApi = InfraDIDConstructor(config: idConfig)
   didApi.actionPubKeyDID(actionName: .setAccount, key: "svc/MessagingService", value: "https://infradid.com/acc/1/mysvcr7", newKey: "")
```

### DID Resolver Getting

```swift
   let infraDidResolver = getResolver(options: MultiNetworkConfiguration(networks: [NetworkConfiguration(networkId: "01", registryContract: "fmapkumrotfc",                                                                                  rpcEndpoint: "https://api.testnet.eos.io")], noRevocationCheck: false))
    
   let didResolver = Resolver(registry: ResolverRegistry(methodName: infraDidResolver), options: ResolverOptions(cache: ResolverOptionsType.bool(true),                                                                                                                              legacyResolver: nil))
```

### Create And Verify Verifiable Credential JWT
```swift
   let idConfig: IdConfiguration =
    IdConfiguration(
      did: "did:infra:01:PUB_K1_6bHxkmnSJQCD1AA5cARqsXDGUWY5ScVxtkwdb71quQVJ5E1JTH",
      didOwnerPrivateKey:"PVT_K1_5K9H1nzqyBAmuuvWCyVgsFciVsiSike1L38WG6Y6LjcssBmNpvT", networkId: "01",
      registryContract: "infradidregi",
      rpcEndpoint: "https://api.testnet.infrablockchain.com",
      jwtSigner: nil,
      txfeePayAccount: "txfeepayeraa",
      txfeePayerPrivateKey:"TXFEE_PAYER_PRIVATE_KEY", pubKeyDidSignDataPrefix: nil)
    
   let infraDidResolver = getResolver(options: MultiNetworkConfiguration(networks: [NetworkConfiguration(networkId: "01", registryContract: "fmapkumrotfc",                                                                                  rpcEndpoint: "https://api.testnet.eos.io")], noRevocationCheck: false))
    
   let didResolver = Resolver(registry: ResolverRegistry(methodName: infraDidResolver), options: ResolverOptions(cache: ResolverOptionsType.bool(true),                                                                                                                              legacyResolver: nil))
    
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
    DispatchQueue.global().async {
      let vc = createVerifiableCredentialJwt(payload: payload, issuer: issuer)
      let vcVerified = verifyCredential(credential: vc, resolver: didResolver)
    }

    print(vcVerified)
```

Verified Credential Result
```swift
   {
  "verifiable_credential" : {
    "@context" : [
      "https:\/\/www.w3.org\/2018\/credentials\/v1",
      "https:\/\/coov.io\/docs\/v1\/vc\/personal"
    ],
    "credential_status" : {
      "id" : "",
      "type" : ""
    },
    "credential_subject" : {
      "name" : "김준형"
    },
    "issuance_date" : "2021-07-29T05:40:02Z",
    "issuer" : {
      "id" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC"
    },
    "proof" : {
      "jwt" : "eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJ2YyI6eyJpZCI6ImRpZDppbmZyYTowMTpQVUJfSzFfNWt6TVA0ZVYzRDRRU0tLNWhoWWpYWW53aVJBVjVzaGsyam5oclFCWnFUQndHUzZ5VTciLCJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vY29vdi5pby9kb2NzL3YxL3ZjL3BlcnNvbmFsIl0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJQZXJzb25hbCJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJuYW1lIjoi6rmA7KSA7ZiVIn19LCJzdWIiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZEOUhXaXFTcXVxdE1tVlU4UHJpdUQ1NjJQeEE0Y2ZNM251N1RtVUU5VVg5ODRmam9zIiwibmJmIjoxNjI3NTM3MjAyLCJpc3MiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZXR3J2bnVHN3hGeENGQTRkUHJlZmg5M0hVZEc3ZDFmalVRTnNaWFE2SmZSQzZHM1pDIn0.vOS-JvMZOQAxsnd8-IeIuwGtK5q0QEHEFxF2hUuLpBIE24M8TQZgp3E0Hgniy2bI6_ZfIa5jlG3_9r_ce-Fryw",
      "type" : "JwtProof2020"
    },
    "type" : [
      "VerifiableCredential",
      "Personal"
    ]
  },
  "verified_jwt" : {
    "did_resolution_result" : {
      "did_document" : {
        "@context" : [
          "https:\/\/www.w3.org\/ns\/did\/v1"
        ],
        "assertion_method" : [

        ],
        "authentication" : [
          "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC#controller"
        ],
        "capability_delegation" : [

        ],
        "capability_invocation" : [

        ],
        "id" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC",
        "verification_method" : [
          {
            "controller" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC",
            "id" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC#controller",
            "public_key_hex" : "02d4f30f6b31a7eb007642cf5e7d7eb12a3db7234cab7da2e84ee78726eb4e3aee",
            "type" : "EcdsaSecp256k1VerificationKey2019"
          }
        ]
      },
      "did_document_metadata" : {
        "deactivated" : true
      },
      "did_resolution_metadata" : {
        "content_type" : "application\/did+ld+json"
      }
    },
    "issuer" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC",
    "jwt" : "eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJ2YyI6eyJpZCI6ImRpZDppbmZyYTowMTpQVUJfSzFfNWt6TVA0ZVYzRDRRU0tLNWhoWWpYWW53aVJBVjVzaGsyam5oclFCWnFUQndHUzZ5VTciLCJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vY29vdi5pby9kb2NzL3YxL3ZjL3BlcnNvbmFsIl0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJQZXJzb25hbCJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJuYW1lIjoi6rmA7KSA7ZiVIn19LCJzdWIiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZEOUhXaXFTcXVxdE1tVlU4UHJpdUQ1NjJQeEE0Y2ZNM251N1RtVUU5VVg5ODRmam9zIiwibmJmIjoxNjI3NTM3MjAyLCJpc3MiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZXR3J2bnVHN3hGeENGQTRkUHJlZmg5M0hVZEc3ZDFmalVRTnNaWFE2SmZSQzZHM1pDIn0.vOS-JvMZOQAxsnd8-IeIuwGtK5q0QEHEFxF2hUuLpBIE24M8TQZgp3E0Hgniy2bI6_ZfIa5jlG3_9r_ce-Fryw",
    "payload" : {
      "iss" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC",
      "nbf" : "2021-07-29T05:40:02.000",
      "sub" : "did:infra:01:PUB_K1_6D9HWiqSquqtMmVU8PriuD562PxA4cfM3nu7TmUE9UX984fjos",
      "vc" : {
        "@context" : [
          "https:\/\/www.w3.org\/2018\/credentials\/v1",
          "https:\/\/coov.io\/docs\/v1\/vc\/personal"
        ],
        "credential_subject" : {
          "name" : "김준형"
        },
        "type" : [
          "VerifiableCredential",
          "Personal"
        ]
      }
    },
    "signer" : {
      "controller" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC",
      "id" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC#controller",
      "public_key_hex" : "02d4f30f6b31a7eb007642cf5e7d7eb12a3db7234cab7da2e84ee78726eb4e3aee",
      "type" : "EcdsaSecp256k1VerificationKey2019"
    }
  }
}

```
### Create And Verify Verifiable Presentation JWT
```swift 
   let idConfig: IdConfiguration =
    IdConfiguration(
      did: "did:infra:01:PUB_K1_6bHxkmnSJQCD1AA5cARqsXDGUWY5ScVxtkwdb71quQVJ5E1JTH",
      didOwnerPrivateKey:"PVT_K1_5K9H1nzqyBAmuuvWCyVgsFciVsiSike1L38WG6Y6LjcssBmNpvT", networkId: "01",
      registryContract: "infradidregi",
      rpcEndpoint: "https://api.testnet.infrablockchain.com",
      jwtSigner: nil,
      txfeePayAccount: "txfeepayeraa",
      txfeePayerPrivateKey:"TXFEE_PAYER_PRIVATE_KEY", pubKeyDidSignDataPrefix: nil)
    
   let infraDidResolver = getResolver(options: MultiNetworkConfiguration(networks: [NetworkConfiguration(networkId: "01", registryContract: "fmapkumrotfc",                                                                                  rpcEndpoint: "https://api.testnet.eos.io")], noRevocationCheck: false))
    
   let didResolver = Resolver(registry: ResolverRegistry(methodName: infraDidResolver), options: ResolverOptions(cache: ResolverOptionsType.bool(true),                                                                                                                              legacyResolver: nil))
    
    let didApi = InfraDIDConstructor(config: idConfig)
    let formatter = ISO8601DateFormatter.init()
    let holder = didApi.getJWTIssuer()
    let payload = PresentationPayload(context: ["https://www.w3.org/2018/credentials/v1"], type: ["VerifiablePresentation"], 
    verifiableCredential:                     VerifiableCredentialType.string(["eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJ2YyI6eyJpZCI6ImRpZDppbmZyYTowMTpQVUJfSzFfNWt6TVA0ZVYzRDRRU0tLNWhoWWpYWW53aVJBVjVzaGsyam5oclFCWnFUQndHUzZ5VTciLCJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vY29vdi5pby9kb2NzL3YxL3ZjL3BlcnNvbmFsIl0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJQZXJzb25hbCJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJuYW1lIjoi6rmA7KSA7ZiVIn19LCJzdWIiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZEOUhXaXFTcXVxdE1tVlU4UHJpdUQ1NjJQeEE0Y2ZNM251N1RtVUU5VVg5ODRmam9zIiwibmJmIjoxNjI3NTM3MjAyLCJpc3MiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZXR3J2bnVHN3hGeENGQTRkUHJlZmg5M0hVZEc3ZDFmalVRTnNaWFE2SmZSQzZHM1pDIn0.vOS-JvMZOQAxsnd8-IeIuwGtK5q0QEHEFxF2hUuLpBIE24M8TQZgp3E0Hgniy2bI6_ZfIa5jlG3_9r_ce-Fryw"]), 
    holder: did, id: nil, verifier: ["did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz"], issuanceDate: formatter.string(from: Date.now),         expirationDate: formatter.string(from: Date(timeIntervalSince1970: (Double(Date.now.timeIntervalSince1970) + 10*60*1000))))
    
    DispatchQueue.global().async {
      let vp = createVerifiablePresentationJwt(payload: payload, holder: holder)
      
      let vpVerified = verifyPresentation(presentation: vp, resolver: didResolver, options: 
    PresentationOptions(audience:                                                                                                                               "did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz", vcValidateFlag: true))
    }
    
    
    print(vpVerified)
```
Verified Presentation Result
```swift
   {
  "verifiable_credentials" : [
    {
      "verifiable_credential" : {
        "@context" : [
          "https:\/\/www.w3.org\/2018\/credentials\/v1",
          "https:\/\/coov.io\/docs\/v1\/vc\/personal"
        ],
        "credential_status" : {
          "id" : "",
          "type" : ""
        },
        "credential_subject" : {
          "name" : "김준형"
        },
        "issuance_date" : "2021-07-29T05:40:02Z",
        "issuer" : {
          "id" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC"
        },
        "proof" : {
          "jwt" : "eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJ2YyI6eyJpZCI6ImRpZDppbmZyYTowMTpQVUJfSzFfNWt6TVA0ZVYzRDRRU0tLNWhoWWpYWW53aVJBVjVzaGsyam5oclFCWnFUQndHUzZ5VTciLCJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vY29vdi5pby9kb2NzL3YxL3ZjL3BlcnNvbmFsIl0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJQZXJzb25hbCJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJuYW1lIjoi6rmA7KSA7ZiVIn19LCJzdWIiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZEOUhXaXFTcXVxdE1tVlU4UHJpdUQ1NjJQeEE0Y2ZNM251N1RtVUU5VVg5ODRmam9zIiwibmJmIjoxNjI3NTM3MjAyLCJpc3MiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZXR3J2bnVHN3hGeENGQTRkUHJlZmg5M0hVZEc3ZDFmalVRTnNaWFE2SmZSQzZHM1pDIn0.vOS-JvMZOQAxsnd8-IeIuwGtK5q0QEHEFxF2hUuLpBIE24M8TQZgp3E0Hgniy2bI6_ZfIa5jlG3_9r_ce-Fryw",
          "type" : "JwtProof2020"
        },
        "type" : [
          "VerifiableCredential",
          "Personal"
        ]
      },
      "verified_jwt" : {
        "did_resolution_result" : {
          "did_document" : {
            "@context" : [
              "https:\/\/www.w3.org\/ns\/did\/v1"
            ],
            "assertion_method" : [

            ],
            "authentication" : [
              "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC#controller"
            ],
            "capability_delegation" : [

            ],
            "capability_invocation" : [

            ],
            "id" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC",
            "verification_method" : [
              {
                "controller" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC",
                "id" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC#controller",
                "public_key_hex" : "02d4f30f6b31a7eb007642cf5e7d7eb12a3db7234cab7da2e84ee78726eb4e3aee",
                "type" : "EcdsaSecp256k1VerificationKey2019"
              }
            ]
          },
          "did_document_metadata" : {
            "deactivated" : true
          },
          "did_resolution_metadata" : {
            "content_type" : "application\/did+ld+json"
          }
        },
        "issuer" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC",
        "jwt" : "eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJ2YyI6eyJpZCI6ImRpZDppbmZyYTowMTpQVUJfSzFfNWt6TVA0ZVYzRDRRU0tLNWhoWWpYWW53aVJBVjVzaGsyam5oclFCWnFUQndHUzZ5VTciLCJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vY29vdi5pby9kb2NzL3YxL3ZjL3BlcnNvbmFsIl0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJQZXJzb25hbCJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJuYW1lIjoi6rmA7KSA7ZiVIn19LCJzdWIiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZEOUhXaXFTcXVxdE1tVlU4UHJpdUQ1NjJQeEE0Y2ZNM251N1RtVUU5VVg5ODRmam9zIiwibmJmIjoxNjI3NTM3MjAyLCJpc3MiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZXR3J2bnVHN3hGeENGQTRkUHJlZmg5M0hVZEc3ZDFmalVRTnNaWFE2SmZSQzZHM1pDIn0.vOS-JvMZOQAxsnd8-IeIuwGtK5q0QEHEFxF2hUuLpBIE24M8TQZgp3E0Hgniy2bI6_ZfIa5jlG3_9r_ce-Fryw",
        "payload" : {
          "iss" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC",
          "nbf" : "2021-07-29T05:40:02.000",
          "sub" : "did:infra:01:PUB_K1_6D9HWiqSquqtMmVU8PriuD562PxA4cfM3nu7TmUE9UX984fjos",
          "vc" : {
            "@context" : [
              "https:\/\/www.w3.org\/2018\/credentials\/v1",
              "https:\/\/coov.io\/docs\/v1\/vc\/personal"
            ],
            "credential_subject" : {
              "name" : "김준형"
            },
            "type" : [
              "VerifiableCredential",
              "Personal"
            ]
          }
        },
        "signer" : {
          "controller" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC",
          "id" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC#controller",
          "public_key_hex" : "02d4f30f6b31a7eb007642cf5e7d7eb12a3db7234cab7da2e84ee78726eb4e3aee",
          "type" : "EcdsaSecp256k1VerificationKey2019"
        }
      }
    }
  ],
  "verifiable_presentation" : {
    "context" : [
      "https:\/\/www.w3.org\/2018\/credentials\/v1"
    ],
    "expiration_date" : "2021-12-30T02:52:13Z",
    "holder" : "did:infra:01:PUB_K1_8emfyTuZvjpCCpsfuzaLZgDvSyvcycoe29EEDH8B8Y6AAU6AV9",
    "issuance_date" : "2021-12-30T02:42:13Z",
    "proof" : {
      "jwt" : "eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJuYmYiOjE2NDA4MzIxMzMsImV4cCI6MTY0MDgzMjczMywiaXNzIjoiZGlkOmluZnJhOjAxOlBVQl9LMV84ZW1meVR1WnZqcENDcHNmdXphTFpnRHZTeXZjeWNvZTI5RUVESDhCOFk2QUFVNkFWOSIsInZwIjp7IkBjb250ZXh0IjpbImh0dHBzOlwvXC93d3cudzMub3JnXC8yMDE4XC9jcmVkZW50aWFsc1wvdjEiXSwidHlwZSI6WyJWZXJpZmlhYmxlUHJlc2VudGF0aW9uIl0sInZlcmlmaWFibGVDcmVkZW50aWFsIjpbImV5SmhiR2NpT2lKRlV6STFOa3NpTENKMGVYQWlPaUpLVjFRaWZRLmV5SjJZeUk2ZXlKcFpDSTZJbVJwWkRwcGJtWnlZVG93TVRwUVZVSmZTekZmTld0NlRWQTBaVll6UkRSUlUwdExOV2hvV1dwWVdXNTNhVkpCVmpWemFHc3lhbTVvY2xGQ1duRlVRbmRIVXpaNVZUY2lMQ0pBWTI5dWRHVjRkQ0k2V3lKb2RIUndjem92TDNkM2R5NTNNeTV2Y21jdk1qQXhPQzlqY21Wa1pXNTBhV0ZzY3k5Mk1TSXNJbWgwZEhCek9pOHZZMjl2ZGk1cGJ5OWtiMk56TDNZeEwzWmpMM0JsY25OdmJtRnNJbDBzSW5SNWNHVWlPbHNpVm1WeWFXWnBZV0pzWlVOeVpXUmxiblJwWVd3aUxDSlFaWEp6YjI1aGJDSmRMQ0pqY21Wa1pXNTBhV0ZzVTNWaWFtVmpkQ0k2ZXlKdVlXMWxJam9pNnJtQTdLU0E3WmlWSW4xOUxDSnpkV0lpT2lKa2FXUTZhVzVtY21FNk1ERTZVRlZDWDBzeFh6WkVPVWhYYVhGVGNYVnhkRTF0VmxVNFVISnBkVVExTmpKUWVFRTBZMlpOTTI1MU4xUnRWVVU1VlZnNU9EUm1hbTl6SWl3aWJtSm1Jam94TmpJM05UTTNNakF5TENKcGMzTWlPaUprYVdRNmFXNW1jbUU2TURFNlVGVkNYMHN4WHpaWFIzSjJiblZITjNoR2VFTkdRVFJrVUhKbFptZzVNMGhWWkVjM1pERm1hbFZSVG5OYVdGRTJTbVpTUXpaSE0xcERJbjAudk9TLUp2TVpPUUF4c25kOC1JZUl1d0d0SzVxMFFFSEVGeEYyaFV1THBCSUUyNE04VFFaZ3AzRTBIZ25peTJiSTZfWmZJYTVqbEczXzlyX2NlLUZyeXciXX0sImF1ZCI6WyJkaWQ6aW5mcmE6MDE6UFVCX0sxXzVUYUVncFZ1cjM5MWRpbVZuRkNESEIxMjJEWFlCYndXZEtVcEVKQ052M2tvMUtNWXd6Il0sImlhdCI6MTY0MDgzMjEzNC4wMzE4MjUxfQ.Km4Qck2hr-z_j8kKJEqE0mfrpn4dMZEQKQHmbroNwfRsbpe7oOnWz3o1gwCzhqiwsZWCS65xRYx2JPfshUFU_g",
      "type" : "JwtProof2020"
    },
    "type" : [
      "VerifiablePresentation"
    ],
    "verifiable_credential" : [
      {
        "@context" : [
          "https:\/\/www.w3.org\/2018\/credentials\/v1",
          "https:\/\/coov.io\/docs\/v1\/vc\/personal"
        ],
        "credential_status" : {
          "id" : "",
          "type" : ""
        },
        "credential_subject" : {
          "name" : "김준형"
        },
        "issuance_date" : "2021-07-29T05:40:02Z",
        "issuer" : {
          "id" : "did:infra:01:PUB_K1_6WGrvnuG7xFxCFA4dPrefh93HUdG7d1fjUQNsZXQ6JfRC6G3ZC"
        },
        "proof" : {
          "jwt" : "eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJ2YyI6eyJpZCI6ImRpZDppbmZyYTowMTpQVUJfSzFfNWt6TVA0ZVYzRDRRU0tLNWhoWWpYWW53aVJBVjVzaGsyam5oclFCWnFUQndHUzZ5VTciLCJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vY29vdi5pby9kb2NzL3YxL3ZjL3BlcnNvbmFsIl0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJQZXJzb25hbCJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJuYW1lIjoi6rmA7KSA7ZiVIn19LCJzdWIiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZEOUhXaXFTcXVxdE1tVlU4UHJpdUQ1NjJQeEE0Y2ZNM251N1RtVUU5VVg5ODRmam9zIiwibmJmIjoxNjI3NTM3MjAyLCJpc3MiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZXR3J2bnVHN3hGeENGQTRkUHJlZmg5M0hVZEc3ZDFmalVRTnNaWFE2SmZSQzZHM1pDIn0.vOS-JvMZOQAxsnd8-IeIuwGtK5q0QEHEFxF2hUuLpBIE24M8TQZgp3E0Hgniy2bI6_ZfIa5jlG3_9r_ce-Fryw",
          "type" : "JwtProof2020"
        },
        "type" : [
          "VerifiableCredential",
          "Personal"
        ]
      }
    ],
    "verifier" : [
      "did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz"
    ]
  },
  "verified_jwt" : {
    "did_resolution_result" : {
      "did_document" : {
        "@context" : [
          "https:\/\/www.w3.org\/ns\/did\/v1"
        ],
        "assertion_method" : [

        ],
        "authentication" : [
          "did:infra:01:PUB_K1_8emfyTuZvjpCCpsfuzaLZgDvSyvcycoe29EEDH8B8Y6AAU6AV9#controller"
        ],
        "capability_delegation" : [

        ],
        "capability_invocation" : [

        ],
        "id" : "did:infra:01:PUB_K1_8emfyTuZvjpCCpsfuzaLZgDvSyvcycoe29EEDH8B8Y6AAU6AV9",
        "verification_method" : [
          {
            "controller" : "did:infra:01:PUB_K1_8emfyTuZvjpCCpsfuzaLZgDvSyvcycoe29EEDH8B8Y6AAU6AV9",
            "id" : "did:infra:01:PUB_K1_8emfyTuZvjpCCpsfuzaLZgDvSyvcycoe29EEDH8B8Y6AAU6AV9#controller",
            "public_key_hex" : "03efa27144baf407514597efda0a3b56e607e79a5c2a314a66ec88764fc3655c7a",
            "type" : "EcdsaSecp256k1VerificationKey2019"
          }
        ]
      },
      "did_document_metadata" : {
        "deactivated" : false
      },
      "did_resolution_metadata" : {
        "content_type" : "application\/did+ld+json"
      }
    },
    "issuer" : "did:infra:01:PUB_K1_8emfyTuZvjpCCpsfuzaLZgDvSyvcycoe29EEDH8B8Y6AAU6AV9",
    "jwt" : "eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJuYmYiOjE2NDA4MzIxMzMsImV4cCI6MTY0MDgzMjczMywiaXNzIjoiZGlkOmluZnJhOjAxOlBVQl9LMV84ZW1meVR1WnZqcENDcHNmdXphTFpnRHZTeXZjeWNvZTI5RUVESDhCOFk2QUFVNkFWOSIsInZwIjp7IkBjb250ZXh0IjpbImh0dHBzOlwvXC93d3cudzMub3JnXC8yMDE4XC9jcmVkZW50aWFsc1wvdjEiXSwidHlwZSI6WyJWZXJpZmlhYmxlUHJlc2VudGF0aW9uIl0sInZlcmlmaWFibGVDcmVkZW50aWFsIjpbImV5SmhiR2NpT2lKRlV6STFOa3NpTENKMGVYQWlPaUpLVjFRaWZRLmV5SjJZeUk2ZXlKcFpDSTZJbVJwWkRwcGJtWnlZVG93TVRwUVZVSmZTekZmTld0NlRWQTBaVll6UkRSUlUwdExOV2hvV1dwWVdXNTNhVkpCVmpWemFHc3lhbTVvY2xGQ1duRlVRbmRIVXpaNVZUY2lMQ0pBWTI5dWRHVjRkQ0k2V3lKb2RIUndjem92TDNkM2R5NTNNeTV2Y21jdk1qQXhPQzlqY21Wa1pXNTBhV0ZzY3k5Mk1TSXNJbWgwZEhCek9pOHZZMjl2ZGk1cGJ5OWtiMk56TDNZeEwzWmpMM0JsY25OdmJtRnNJbDBzSW5SNWNHVWlPbHNpVm1WeWFXWnBZV0pzWlVOeVpXUmxiblJwWVd3aUxDSlFaWEp6YjI1aGJDSmRMQ0pqY21Wa1pXNTBhV0ZzVTNWaWFtVmpkQ0k2ZXlKdVlXMWxJam9pNnJtQTdLU0E3WmlWSW4xOUxDSnpkV0lpT2lKa2FXUTZhVzVtY21FNk1ERTZVRlZDWDBzeFh6WkVPVWhYYVhGVGNYVnhkRTF0VmxVNFVISnBkVVExTmpKUWVFRTBZMlpOTTI1MU4xUnRWVVU1VlZnNU9EUm1hbTl6SWl3aWJtSm1Jam94TmpJM05UTTNNakF5TENKcGMzTWlPaUprYVdRNmFXNW1jbUU2TURFNlVGVkNYMHN4WHpaWFIzSjJiblZITjNoR2VFTkdRVFJrVUhKbFptZzVNMGhWWkVjM1pERm1hbFZSVG5OYVdGRTJTbVpTUXpaSE0xcERJbjAudk9TLUp2TVpPUUF4c25kOC1JZUl1d0d0SzVxMFFFSEVGeEYyaFV1THBCSUUyNE04VFFaZ3AzRTBIZ25peTJiSTZfWmZJYTVqbEczXzlyX2NlLUZyeXciXX0sImF1ZCI6WyJkaWQ6aW5mcmE6MDE6UFVCX0sxXzVUYUVncFZ1cjM5MWRpbVZuRkNESEIxMjJEWFlCYndXZEtVcEVKQ052M2tvMUtNWXd6Il0sImlhdCI6MTY0MDgzMjEzNC4wMzE4MjUxfQ.Km4Qck2hr-z_j8kKJEqE0mfrpn4dMZEQKQHmbroNwfRsbpe7oOnWz3o1gwCzhqiwsZWCS65xRYx2JPfshUFU_g",
    "payload" : {
      "aud" : [
        "did:infra:01:PUB_K1_5TaEgpVur391dimVnFCDHB122DXYBbwWdKUpEJCNv3ko1KMYwz"
      ],
      "exp" : "2021-12-30T02:52:13.000",
      "iat" : "2021-12-30T02:42:14.032",
      "iss" : "did:infra:01:PUB_K1_8emfyTuZvjpCCpsfuzaLZgDvSyvcycoe29EEDH8B8Y6AAU6AV9",
      "nbf" : "2021-12-30T02:42:13.000",
      "vp" : {
        "@context" : [
          "https:\/\/www.w3.org\/2018\/credentials\/v1"
        ],
        "type" : [
          "VerifiablePresentation"
        ],
        "verifiable_credential" : [
          "eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJ2YyI6eyJpZCI6ImRpZDppbmZyYTowMTpQVUJfSzFfNWt6TVA0ZVYzRDRRU0tLNWhoWWpYWW53aVJBVjVzaGsyam5oclFCWnFUQndHUzZ5VTciLCJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vY29vdi5pby9kb2NzL3YxL3ZjL3BlcnNvbmFsIl0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJQZXJzb25hbCJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJuYW1lIjoi6rmA7KSA7ZiVIn19LCJzdWIiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZEOUhXaXFTcXVxdE1tVlU4UHJpdUQ1NjJQeEE0Y2ZNM251N1RtVUU5VVg5ODRmam9zIiwibmJmIjoxNjI3NTM3MjAyLCJpc3MiOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzZXR3J2bnVHN3hGeENGQTRkUHJlZmg5M0hVZEc3ZDFmalVRTnNaWFE2SmZSQzZHM1pDIn0.vOS-JvMZOQAxsnd8-IeIuwGtK5q0QEHEFxF2hUuLpBIE24M8TQZgp3E0Hgniy2bI6_ZfIa5jlG3_9r_ce-Fryw"
        ]
      }
    },
    "signer" : {
      "controller" : "did:infra:01:PUB_K1_8emfyTuZvjpCCpsfuzaLZgDvSyvcycoe29EEDH8B8Y6AAU6AV9",
      "id" : "did:infra:01:PUB_K1_8emfyTuZvjpCCpsfuzaLZgDvSyvcycoe29EEDH8B8Y6AAU6AV9#controller",
      "public_key_hex" : "03efa27144baf407514597efda0a3b56e607e79a5c2a314a66ec88764fc3655c7a",
      "type" : "EcdsaSecp256k1VerificationKey2019"
    }
  }
}
```

## Installation

<!-- - **Using  [CocoaPods](https://cocoapods.org)**:

    ```ruby
    pod 'Then'
    ```
 -->
- **Using [Swift Package Manager](https://swift.org/package-manager)**:

    ```swift
    import PackageDescription

    let package = Package(
      name: "MyAwesomeApp",
      dependencies: [
        .Package(url: "https://github.com/InfraBlockchain/Infra-DID-Swift", branch: "master")
      ]
    )
    ```
    
## API Documentation
   For more information visit our [API reference](https://kitura.github.io/Swift-JWT/index.html).

## License

**Infra-DID-Swift** is under MIT license. See the [LICENSE](https://github.com/InfraBlockchain/Infra-DID-Swift/blob/master/LICENSE) file for more info.
