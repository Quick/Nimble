import Foundation
import Nimble
import XCTest

protocol FailureMessageEquatable {
    func matchesFailureMessage(message: String) -> Bool
}

extension String: FailureMessageEquatable {
    func matchesFailureMessage(message: String) -> Bool {
        return self == message
    }
}

extension NSRegularExpression: FailureMessageEquatable {
    func matchesFailureMessage(message: String) -> Bool {
        let entireString = NSRange(location: 0, length: message.characters.count)
        return !matchesInString(message, options: NSMatchingOptions(), range: entireString).isEmpty
    }
}

extension NSString: FailureMessageEquatable {
    func matchesFailureMessage(message: String) -> Bool {
        return isEqualToString(message)
    }
}

func failsWithErrorMessage(expectedFailureMessages: [FailureMessageEquatable], file: String = __FILE__, line: UInt = __LINE__, preferOriginalSourceLocation: Bool = false, closure: () throws -> Void) {
    var filePath = file
    var lineNumber = line

    let recorder = AssertionRecorder()
    withAssertionHandler(recorder, closure: closure)

    for expectedMessage in expectedFailureMessages {
        var lastFailure: AssertionRecord?
        var foundFailureMessage = false

        for assertion in recorder.assertions {
            lastFailure = assertion
            if expectedMessage.matchesFailureMessage(assertion.message.stringValue) {
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

        if let lastFailure = lastFailure {
            let msg = "Got failure message: \"\(lastFailure.message.stringValue)\", but expected \"\(expectedMessage)\""
            XCTFail(msg, file: filePath, line: lineNumber)
        } else {
            XCTFail("expected failure message, but got none", file: filePath, line: lineNumber)
        }
    }
}

func failsWithErrorMessage(message: FailureMessageEquatable, file: String = __FILE__, line: UInt = __LINE__, preferOriginalSourceLocation: Bool = false, closure: () -> Void) {
    return failsWithErrorMessage(
        [message],
        file: file,
        line: line,
        preferOriginalSourceLocation: preferOriginalSourceLocation,
        closure: closure
    )
}

func failsWithErrorMessageForNil(message: FailureMessageEquatable, file: String = __FILE__, line: UInt = __LINE__, preferOriginalSourceLocation: Bool = false, closure: () -> Void) {
    failsWithErrorMessage("\(message) (use beNil() to match nils)", file: file, line: line, preferOriginalSourceLocation: preferOriginalSourceLocation, closure: closure)
}

func deferToMainQueue(action: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        NSThread.sleepForTimeInterval(0.01)
        action()
    }
}

public class NimbleHelper : NSObject {
    class func expectFailureMessage(message: NSString, block: () -> Void, file: String, line: UInt) {
        failsWithErrorMessage(message as FailureMessageEquatable, file: file, line: line, preferOriginalSourceLocation: true, closure: block)
    }

    class func expectFailureMessages(messages: [NSString], block: () -> Void, file: String, line: UInt) {
        failsWithErrorMessage(messages.map { $0 as FailureMessageEquatable }, file: file, line: line, preferOriginalSourceLocation: true, closure: block)
    }

    class func expectFailureMessageForNil(message: NSString, block: () -> Void, file: String, line: UInt) {
        failsWithErrorMessageForNil(message as FailureMessageEquatable, file: file, line: line, preferOriginalSourceLocation: true, closure: block)
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