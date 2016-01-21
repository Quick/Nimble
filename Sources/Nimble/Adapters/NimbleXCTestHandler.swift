import Foundation
import XCTest

/// Default handler for Nimble. This assertion handler passes failures along to
/// XCTest.
public class NimbleXCTestHandler : AssertionHandler {
    public func assert(assertion: Bool, message: FailureMessage, location: SourceLocation) {
        if !assertion {
            XCTFail("\(message.stringValue)\n", file: location.file, line: location.line)
        }
    }
}

/// Alternative handler for Nimble. This assertion handler passes failures along
/// to XCTest by attempting to reduce the failure message size.
public class NimbleShortXCTestHandler: AssertionHandler {
    public func assert(assertion: Bool, message: FailureMessage, location: SourceLocation) {
        if !assertion {
            let msg: String
            if let actual = message.actualValue {
                msg = "got: \(actual) \(message.postfixActual)"
            } else {
                msg = "expected \(message.to) \(message.postfixMessage)"
            }
            XCTFail("\(msg)\n", file: location.file, line: location.line)
        }
    }
}

/// Fallback handler in case XCTest is unavailable. This assertion handler will abort
/// the program if it is invoked.
class NimbleXCTestUnavailableHandler : AssertionHandler {
    func assert(assertion: Bool, message: FailureMessage, location: SourceLocation) {
        fatalError("XCTest is not available and no custom assertion handler was configured. Aborting.")
    }
}

func isXCTestAvailable() -> Bool {
#if _runtime(_ObjC)
    // XCTest is weakly linked and so may not be present
    return NSClassFromString("XCTestCase") != nil
#else
    return true
#endif
}
