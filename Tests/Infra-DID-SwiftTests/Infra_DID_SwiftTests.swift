import XCTest
@testable import Infra_DID_Swift

final class Infra_DID_SwiftTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
      print(InfraDIDConstructor())
        XCTAssertEqual(Infra_DID_Swift().text, "Hello, World!")
    }
}
