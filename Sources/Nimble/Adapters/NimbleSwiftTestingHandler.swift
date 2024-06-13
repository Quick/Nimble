import Foundation
#if canImport(Testing)
import Testing
#endif

public class NimbleSwiftTestingHandler: AssertionHandler {
    public func assert(_ assertion: Bool, message: FailureMessage, location: SourceLocation) {
        if !assertion {
            recordTestingFailure("\(message.stringValue)\n", location: location)
        }
    }
}

func isSwiftTestingAvailable() -> Bool {
#if canImport(Testing)
    true
#else
    false
#endif
}

func isRunningSwiftTest() -> Bool {
#if canImport(Testing)
    Test.current != nil
#else
    false
#endif
}

public func recordTestingFailure(_ message: String, location: SourceLocation) {
#if canImport(Testing)
    Issue.record("\(message)", filePath: "\(location.file)", line: Int(location.line), column: 0)
#endif
}
