import Foundation

protocol AssertionHandler {
    func assert(assertion: Bool, message: String, file: String, line: Int)
}

var CurrentAssertionHandler: AssertionHandler = XCTestHandler()

