import Foundation
import XCTest

/// Default handler for Nimble. This assertion handler passes failures along to
/// XCTest.
public class NimbleXCTestHandler: AssertionHandler {
    public func assert(_ assertion: Bool, message: FailureMessage, location: SourceLocation) {
        if !assertion {
            recordFailure("\(message.stringValue)\n", location: location)
        }
    }
}

/// Alternative handler for Nimble. This assertion handler passes failures along
/// to XCTest by attempting to reduce the failure message size.
public class NimbleShortXCTestHandler: AssertionHandler {
    public func assert(_ assertion: Bool, message: FailureMessage, location: SourceLocation) {
        if !assertion {
            let msg: String
            if let actual = message.actualValue {
                msg = "got: \(actual) \(message.postfixActual)"
            } else {
                msg = "expected \(message.to) \(message.postfixMessage)"
            }
            recordFailure("\(msg)\n", location: location)
        }
    }
}

/// Fallback handler in case XCTest is unavailable. This assertion handler will abort
/// the program if it is invoked.
class NimbleXCTestUnavailableHandler: AssertionHandler {
    func assert(_ assertion: Bool, message: FailureMessage, location: SourceLocation) {
        fatalError("XCTest is not available and no custom assertion handler was configured. Aborting.")
    }
}

#if canImport(Darwin)
/// Helper class providing access to the currently executing XCTestCase instance, if any
@objc final public class CurrentTestCaseTracker: NSObject, XCTestObservation {
    @objc public static let sharedInstance = CurrentTestCaseTracker()

    private(set) var currentTestCase: XCTestCase?

    private var stashed_swift_reportFatalErrorsToDebugger: Bool = false

    @objc public func testCaseWillStart(_ testCase: XCTestCase) {
        #if (os(macOS) || os(iOS)) && !SWIFT_PACKAGE
        stashed_swift_reportFatalErrorsToDebugger = _swift_reportFatalErrorsToDebugger
        _swift_reportFatalErrorsToDebugger = false
        #endif

        currentTestCase = testCase
    }

    @objc public func testCaseDidFinish(_ testCase: XCTestCase) {
        currentTestCase = nil

        #if (os(macOS) || os(iOS)) && !SWIFT_PACKAGE
        _swift_reportFatalErrorsToDebugger = stashed_swift_reportFatalErrorsToDebugger
        #endif
    }
}
#endif

func isXCTestAvailable() -> Bool {
#if canImport(Darwin)
    // XCTest is weakly linked and so may not be present
    return NSClassFromString("XCTestCase") != nil
#else
    return true
#endif
}

public func recordFailure(_ message: String, location: SourceLocation) {
#if !canImport(Darwin)
    XCTFail("\(message)", file: location.file, line: location.line)
#else
    if let testCase = CurrentTestCaseTracker.sharedInstance.currentTestCase {
        let line = Int(location.line)
        let location = XCTSourceCodeLocation(filePath: location.file, lineNumber: line)
        let sourceCodeContext = XCTSourceCodeContext(location: location)
        let issue = XCTIssue(type: .assertionFailure, compactDescription: message, sourceCodeContext: sourceCodeContext)
        testCase.record(issue)
    } else {
        let msg = """
            Attempted to report a test failure to XCTest while no test case was running. The failure was:
            \"\(message)\"
            It occurred at: \(location.file):\(location.line)
            """
        NSException(name: .internalInconsistencyException, reason: msg, userInfo: nil).raise()
    }
#endif
}
