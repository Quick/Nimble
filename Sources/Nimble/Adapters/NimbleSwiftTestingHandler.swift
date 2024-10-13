import Foundation
#if canImport(Testing)
// See https://github.com/pointfreeco/swift-snapshot-testing/discussions/901#discussioncomment-10605497
// tl;dr: Swift Testing is not available when using UI tests.
// And apparently `private import` - the preferred way to do this - doesn't work.
// So we use a deprecated approach that does work with this.
@_implementationOnly import Testing
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
    let testingLocation = Testing.SourceLocation(
        fileID: location.fileID,
        filePath: "\(location.filePath)",
        line: Int(location.line),
        column: Int(location.column)
    )

    Testing.Issue.record(
        "\(message)",
        sourceLocation: testingLocation
    )
#endif
}
