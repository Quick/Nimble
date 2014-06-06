import Foundation

// Problem: we can't link XCTest inside a framework or static library.
// Current Solution: Make the user of the library manually link to XCTest
//
// setAssertionRecorder { assertion, message, file, line in
//     XCTAssert(assertion, message, file: file, line: line)
// }

typealias AssertionRecorder = (assertion: Bool, message: String, file: String, line: Int) -> Void
var _assertionRecorder: AssertionRecorder?

func setAssertionRecorder(recorder: AssertionRecorder) {
    _assertionRecorder = recorder
}

func withAssertionRecorder(recorder: AssertionRecorder, closure: () -> Void) {
    let oldRecorder = _assertionRecorder
    let capturer = TSExceptionCapture(handler: nil, finally: ({
        _assertionRecorder = oldRecorder
    }))
    capturer.tryBlock {
        _assertionRecorder = recorder
        closure()
    }
}
