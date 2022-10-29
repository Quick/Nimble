#if !os(WASI)
import Dispatch
#endif
import Foundation
@testable import Nimble
import XCTest

func failsWithErrorMessage(_ messages: [String], file: FileString = #file, line: UInt = #line, preferOriginalSourceLocation: Bool = false, closure: () throws -> Void) {
    var filePath = file
    var lineNumber = line

    let recorder = AssertionRecorder()
    withAssertionHandler(recorder, file: file, line: line, closure: closure)

    for msg in messages {
        var lastFailure: AssertionRecord?
        var foundFailureMessage = false

        for assertion in recorder.assertions where assertion.message.stringValue == msg && !assertion.success {
            lastFailure = assertion
            foundFailureMessage = true
            break
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
            let knownFailures = recorder.assertions.filter { !$0.success }.map { $0.message.stringValue }
            let knownFailuresJoined = knownFailures.joined(separator: ", ")
            message = """
                Expected error message (\(msg)), got (\(knownFailuresJoined))

                Assertions Received:
                \(recorder.assertions)
                """
        }
        NimbleAssertionHandler.assert(false,
                                      message: FailureMessage(stringValue: message),
                                      location: SourceLocation(file: filePath, line: lineNumber))
    }
}

func failsWithErrorMessage(_ message: String, file: FileString = #file, line: UInt = #line, preferOriginalSourceLocation: Bool = false, closure: () throws -> Void) {
    failsWithErrorMessage(
        [message],
        file: file,
        line: line,
        preferOriginalSourceLocation: preferOriginalSourceLocation,
        closure: closure
    )
}

func failsWithErrorMessageForNil(_ message: String, file: FileString = #file, line: UInt = #line, preferOriginalSourceLocation: Bool = false, closure: () throws -> Void) {
    failsWithErrorMessage("\(message) (use beNil() to match nils)", file: file, line: line, preferOriginalSourceLocation: preferOriginalSourceLocation, closure: closure)
}

func failsWithErrorMessage(_ messages: [String], file: FileString = #file, line: UInt = #line, preferOriginalSourceLocation: Bool = false, closure: () async throws -> Void) async {
    var filePath = file
    var lineNumber = line

    let recorder = AssertionRecorder()
    await withAssertionHandler(recorder, file: file, line: line, closure: closure)

    for msg in messages {
        var lastFailure: AssertionRecord?
        var foundFailureMessage = false

        for assertion in recorder.assertions where assertion.message.stringValue == msg && !assertion.success {
            lastFailure = assertion
            foundFailureMessage = true
            break
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
            let knownFailures = recorder.assertions.filter { !$0.success }.map { $0.message.stringValue }
            let knownFailuresJoined = knownFailures.joined(separator: ", ")
            message = """
                Expected error message (\(msg)), got (\(knownFailuresJoined))

                Assertions Received:
                \(recorder.assertions)
                """
        }
        NimbleAssertionHandler.assert(false,
                                      message: FailureMessage(stringValue: message),
                                      location: SourceLocation(file: filePath, line: lineNumber))
    }
}

func failsWithErrorMessage(_ message: String, file: FileString = #file, line: UInt = #line, preferOriginalSourceLocation: Bool = false, closure: () async throws -> Void) async {
    await failsWithErrorMessage(
        [message],
        file: file,
        line: line,
        preferOriginalSourceLocation: preferOriginalSourceLocation,
        closure: closure
    )
}

func failsWithErrorMessageForNil(_ message: String, file: FileString = #file, line: UInt = #line, preferOriginalSourceLocation: Bool = false, closure: () async throws -> Void) async {
    await failsWithErrorMessage("\(message) (use beNil() to match nils)", file: file, line: line, preferOriginalSourceLocation: preferOriginalSourceLocation, closure: closure)
}

@discardableResult
func suppressErrors<T>(closure: () -> T) -> T {
    var output: T?
    let recorder = AssertionRecorder()
    withAssertionHandler(recorder) {
        output = closure()
    }
    return output!
}

func producesStatus<Exp: Expectation, T>(_ status: ExpectationStatus, file: FileString = #file, line: UInt = #line, closure: () -> Exp) where Exp.Value == T {
    let expectation = suppressErrors(closure: closure)

    expect(file: file, line: line, expectation.status).to(equal(status))
}

#if !os(WASI)
func deferToMainQueue(action: @escaping () -> Void) {
    DispatchQueue.main.async {
        Thread.sleep(forTimeInterval: 0.01)
        action()
    }
}
#endif

#if canImport(Darwin) && !SWIFT_PACKAGE
public class NimbleHelper: NSObject {
    @objc public class func expectFailureMessage(_ message: NSString, block: () -> Void, file: FileString, line: UInt) {
        failsWithErrorMessage(String(describing: message), file: file, line: line, preferOriginalSourceLocation: true, closure: block)
    }

    @objc public class func expectFailureMessages(_ messages: [NSString], block: () -> Void, file: FileString, line: UInt) {
        failsWithErrorMessage(messages.map({String(describing: $0)}), file: file, line: line, preferOriginalSourceLocation: true, closure: block)
    }

    @objc public class func expectFailureMessageForNil(_ message: NSString, block: () -> Void, file: FileString, line: UInt) {
        failsWithErrorMessageForNil(String(describing: message), file: file, line: line, preferOriginalSourceLocation: true, closure: block)
    }
}
#endif

#if !os(WASI)
extension Date {
    init(dateTimeString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let date = dateFormatter.date(from: dateTimeString)!
        self.init(timeInterval: 0, since: date)
    }
}

extension NSDate {
    convenience init(dateTimeString: String) {
        let date = Date(dateTimeString: dateTimeString)
        self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
    }
}
#endif
