import Foundation
import Nimble
import XCTest

func failsWithErrorMessage(message: String, closure: () -> Void, file: String = __FILE__, line: UInt = __LINE__, preferOriginalSourceLocation: Bool = false) {
    var filePath = file
    var lineNumber = line

    let recorder = AssertionRecorder()
    withAssertionHandler(recorder, closure)

    var lastFailure: AssertionRecord?
    if recorder.assertions.count > 0 {
        lastFailure = recorder.assertions[recorder.assertions.endIndex - 1]
        if lastFailure!.message == message {
            return
        }
    }

    if preferOriginalSourceLocation {
        if let failure = lastFailure {
            filePath = failure.location.file
            lineNumber = failure.location.line
        }
    }

    if lastFailure != nil {
        let msg = "Got failure message: \"\(lastFailure!.message)\", but expected \"\(message)\""
        XCTFail(msg, file: filePath, line: lineNumber)
    } else {
        XCTFail("expected failure message, but got none", file: filePath, line: lineNumber)
    }
}

func failsWithErrorMessageForNil(message: String, closure: () -> Void, file: String = __FILE__, line: UInt = __LINE__, preferOriginalSourceLocation: Bool = false) {
    failsWithErrorMessage("\(message) (use beNil() to match nils)", closure, file: file, line: line, preferOriginalSourceLocation: preferOriginalSourceLocation)
}

func deferToMainQueue(action: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        NSThread.sleepForTimeInterval(0.01)
        action()
    }
}

public class NimbleHelper : NSObject {
    class func expectFailureMessage(message: NSString, block: () -> Void, file: String, line: UInt) {
        failsWithErrorMessage(message as String, block, file: file, line: line, preferOriginalSourceLocation: true)
    }

    class func expectFailureMessageForNil(message: NSString, block: () -> Void, file: String, line: UInt) {
        failsWithErrorMessageForNil(message as String, block, file: file, line: line, preferOriginalSourceLocation: true)
    }
}
