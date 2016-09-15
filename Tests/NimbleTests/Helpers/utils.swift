import Foundation
@testable import Nimble
import XCTest

func failsWithErrorMessage(_ messages: [String], file: FileString = #file, line: UInt = #line, preferOriginalSourceLocation: Bool = false, closure: @escaping () throws -> Void) {
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

func failsWithErrorMessage(_ message: String, file: FileString = #file, line: UInt = #line, preferOriginalSourceLocation: Bool = false, closure: @escaping () -> Void) {
    return failsWithErrorMessage(
        [message],
        file: file,
        line: line,
        preferOriginalSourceLocation: preferOriginalSourceLocation,
        closure: closure
    )
}

func failsWithErrorMessageForNil(_ message: String, file: FileString = #file, line: UInt = #line, preferOriginalSourceLocation: Bool = false, closure: @escaping () -> Void) {
    failsWithErrorMessage("\(message) (use beNil() to match nils)", file: file, line: line, preferOriginalSourceLocation: preferOriginalSourceLocation, closure: closure)
}

#if _runtime(_ObjC)
    func deferToMainQueue(action: @escaping () -> Void) {
        DispatchQueue.main.async {
            Thread.sleep(forTimeInterval: 0.01)
            action()
        }
    }
#endif

public class NimbleHelper : NSObject {
    public class func expectFailureMessage(_ message: NSString, block: @escaping () -> Void, file: FileString, line: UInt) {
        failsWithErrorMessage(String(describing: message), file: file, line: line, preferOriginalSourceLocation: true, closure: block)
    }

    public class func expectFailureMessages(_ messages: [NSString], block: @escaping () -> Void, file: FileString, line: UInt) {
        failsWithErrorMessage(messages.map({String(describing: $0)}), file: file, line: line, preferOriginalSourceLocation: true, closure: block)
    }

    public class func expectFailureMessageForNil(_ message: NSString, block: @escaping () -> Void, file: FileString, line: UInt) {
        failsWithErrorMessageForNil(String(describing: message), file: file, line: line, preferOriginalSourceLocation: true, closure: block)
    }
}

extension Date {
    init(dateTimeString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let date = dateFormatter.date(from: dateTimeString)!
        self.init(timeInterval:0, since:date)
    }
}

extension NSDate {
    convenience init(dateTimeString: String) {
        let date = Date(dateTimeString: dateTimeString)
        self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
    }
}
