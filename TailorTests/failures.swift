import Foundation
import Tailor
import XCTest

func failsWithErrorMessage(message: String, closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
    var lastFailureMessage: String = ""
    let recorder: AssertionRecorder = ({ assertion, message, file, line in
        lastFailureMessage = message
    })
    withAssertionRecorder(recorder, closure)

    if lastFailureMessage == message {
        return
    }
    XCTFail("Expected failure with message '\(message)', but got message: '\(lastFailureMessage)'", file: file, line: line)
}
