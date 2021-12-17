// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Infra-DID-Swift",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Infra-DID-Swift",
            type: .dynamic,
            targets: ["Infra-DID-Swift"])
//        .library(
//            name: "Utils",
//            type: .dynamic,
//            targets: ["Infra-DID-Swift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
      .package(name: "EosioSwift", url: "https://github.com/EOSIO/eosio-swift", from: "1.0.0"),
      .package(
              name: "secp256k1",
              url: "https://github.com/GigaBitcoin/secp256k1.swift.git",
              from: "0.3.0"
          ),
      .package(url: "https://github.com/Kitura/BlueECC.git", from: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Infra-DID-Swift",
            dependencies: [
                .product(name: "EosioSwift", package: "EosioSwift"),
                .product(name: "EosioSwiftAbieosSerializationProvider", package: "EosioSwift"),
                .product(name: "EosioSwiftEcc", package: "EosioSwift"),
                .product(name: "EosioSwiftSoftkeySignatureProvider", package: "EosioSwift"),
                .product(name: "secp256k1", package: "secp256k1", condition: nil),
                .product(name: "CryptorECC", package: "BlueECC", condition: nil)
        ]),
        .testTarget(
            name: "Infra-DID-SwiftTests",
            dependencies: ["Infra-DID-Swift"]),
    ]
)
