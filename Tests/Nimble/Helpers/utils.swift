import Foundation
@testable import Nimble
import XCTest

func failsWithErrorMessage(messages: [String], file: FileString = __FILE__, line: UInt = __LINE__, preferOriginalSourceLocation: Bool = false, closure: () throws -> Void) {
    var filePath = file
    var lineNumber = line

    let recorder = AssertionRecorder()
    withAssertionHandler(recorder, closure: closure)

    for msg in messages {
        var lastFailure: AssertionRecord?
        var foundFailureMessage = false

        for assertion in recorder.assertions {
            lastFailure = assertion
            if assertion.message.stringValue == msg {
                foundFailureMessage = true
                break
            }
        }

        if foundFailureMessage {
            continue
        }

        if preferOriginalSourceLocation {
            if let failure = lastFailure {
                filePath = failure.location.file
                lineNumber = failure.location.line
            }
        }

        let message: String
        if let lastFailure = lastFailure {
            message = "Got failure message: \"\(lastFailure.message.stringValue)\", but expected \"\(msg)\""
        } else {
            message = "expected failure message, but got none"
        }
        NimbleAssertionHandler.assert(false,
                                      message: FailureMessage(stringValue: message),
                                      location: SourceLocation(file: filePath, line: lineNumber))
    }
}

func failsWithErrorMessage(message: String, file: FileString = __FILE__, line: UInt = __LINE__, preferOriginalSourceLocation: Bool = false, closure: () -> Void) {
    return failsWithErrorMessage(
        [message],
        file: file,
        line: line,
        preferOriginalSourceLocation: preferOriginalSourceLocation,
        closure: closure
    )
}

func failsWithErrorMessageForNil(message: String, file: FileString = __FILE__, line: UInt = __LINE__, preferOriginalSourceLocation: Bool = false, closure: () -> Void) {
    failsWithErrorMessage("\(message) (use beNil() to match nils)", file: file, line: line, preferOriginalSourceLocation: preferOriginalSourceLocation, closure: closure)
}

#if _runtime(_ObjC)
    func deferToMainQueue(action: () -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            NSThread.sleepForTimeInterval(0.01)
            action()
        }
    }
#endif

public class NimbleHelper : NSObject {
    public class func expectFailureMessage(message: NSString, block: () -> Void, file: FileString, line: UInt) {
        failsWithErrorMessage(String(message), file: file, line: line, preferOriginalSourceLocation: true, closure: block)
    }

    public class func expectFailureMessages(messages: [NSString], block: () -> Void, file: FileString, line: UInt) {
        failsWithErrorMessage(messages.map({ String($0) }), file: file, line: line, preferOriginalSourceLocation: true, closure: block)
    }

    public class func expectFailureMessageForNil(message: NSString, block: () -> Void, file: FileString, line: UInt) {
        failsWithErrorMessageForNil(String(message), file: file, line: line, preferOriginalSourceLocation: true, closure: block)
    }
}

extension NSDate {
    convenience init(dateTimeString:String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let date = dateFormatter.dateFromString(dateTimeString)!
        self.init(timeInterval:0, sinceDate:date)
    }
}