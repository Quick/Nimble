import Foundation
import Kick
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
    let msg = "Got failure message: '\(lastFailureMessage)', but expected '\(message)'"
    fail(msg, file: file, line: line)
}
