/// Protocol for the assertion handler that Nimble uses for all expectations.
public protocol AssertionHandler {
    func assert(_ assertion: Bool, message: FailureMessage, location: SourceLocation)
}

/// Global backing interface for assertions that Nimble creates.
/// Defaults to a private test handler that passes through to Swift Testing or XCTest.
///
/// If neither Swift Testing or XCTest is available, you must assign your own assertion handler
/// before using any matchers, otherwise Nimble will abort the program.
///
/// @see AssertionHandler
// make this a task local.
public var NimbleAssertionHandler: AssertionHandler {
    get {
        _assertionHandlerLock.lock()
        defer { _assertionHandlerLock.unlock() }

        return _assertionHandler
    }
    set {
        _assertionHandlerLock.lock()
        defer { _assertionHandlerLock.unlock() }
        _assertionHandler = newValue
    }
}

import Foundation
private let _assertionHandlerLock = NSRecursiveLock()

private var _assertionHandler: AssertionHandler = { () -> AssertionHandler in
    // swiftlint:disable:previous identifier_name
    if isSwiftTestingAvailable() || isXCTestAvailable() {
        return NimbleTestingHandler()
    }

    return NimbleTestingUnavailableHandler()
}()
