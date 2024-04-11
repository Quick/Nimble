/// Protocol for the assertion handler that Nimble uses for all expectations.
public protocol AssertionHandler: Sendable {
    func assert(_ assertion: Bool, message: FailureMessage, location: SourceLocation)
}

/// Global backing interface for assertions that Nimble creates.
/// Defaults to a private test handler that passes through to XCTest.
///
/// If XCTest is not available, you must assign your own assertion handler
/// before using any matchers, otherwise Nimble will abort the program.
///
/// @see AssertionHandler
public var NimbleAssertionHandler: AssertionHandler {
    // swiftlint:disable:previous identifier_name
    get {
        _NimbleAssertionHandler.value
    }
    set {
        _NimbleAssertionHandler.set(newValue)
    }
}
private let _NimbleAssertionHandler = LockedContainer<AssertionHandler> {
    // swiftlint:disable:previous identifier_name
    if isXCTestAvailable() {
        return NimbleXCTestHandler() as AssertionHandler
    } else {
        return NimbleXCTestUnavailableHandler() as AssertionHandler
    }
}
