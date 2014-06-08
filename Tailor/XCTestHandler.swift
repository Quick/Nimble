import Foundation
import XCTest

class XCTestHandler : AssertionHandler {
    func assert(assertion: Bool, message: String, file: String, line: Int) {
        XCTAssert(assertion, message, file: file, line: line)
    }

    func fail(message: String, file: String, line: Int)  {
        XCTFail(message, file: file, line: line)
    }
}
