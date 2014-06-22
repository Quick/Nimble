import Foundation
import Tailor
import XCTest

func failsWithErrorMessage(message: String, closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
    let recorder = AssertionRecorder()
    withAssertionHandler(recorder, closure)

    var lastFailureMessage = ""
    if recorder.assertions.count > 0 {
        lastFailureMessage = recorder.assertions[recorder.assertions.endIndex - 1].message
        if lastFailureMessage == message {
            return
        }
    }
    fail("Expected failure message '\(message)', but got message: '\(lastFailureMessage)'", file: file, line: line)
}
