/// Make a ``SyncExpectation`` on a given actual value. The value given is lazily evaluated.
public func expect<T>(location: SourceLocation = SourceLocation(), _ expression: @autoclosure @escaping @Sendable () throws -> T?) -> SyncExpectation<T> {
    return SyncExpectation(
        expression: Expression(
            expression: expression,
            location: location,
            isClosure: true))
}

/// Make a ``SyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect<T>(location: SourceLocation = SourceLocation(), _ expression: @autoclosure () -> (@Sendable () throws -> T)) -> SyncExpectation<T> {
    return SyncExpectation(
        expression: Expression(
            expression: expression(),
            location: location,
            isClosure: true))
}

/// Make a ``SyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect<T>(location: SourceLocation = SourceLocation(), _ expression: @autoclosure () -> (@Sendable () throws -> T?)) -> SyncExpectation<T> {
    return SyncExpectation(
        expression: Expression(
            expression: expression(),
            location: location,
            isClosure: true))
}

/// Make a ``SyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect(location: SourceLocation = SourceLocation(), _ expression: @autoclosure () -> (@Sendable () throws -> Void)) -> SyncExpectation<Void> {
    return SyncExpectation(
        expression: Expression(
            expression: expression(),
            location: location,
            isClosure: true))
}

/// Make a ``SyncExpectation`` on a given actual value. The value given is lazily evaluated.
/// This is provided as an alternative to `expect` which avoids overloading with `expect -> AsyncExpectation`.
public func expects<T>(location: SourceLocation = SourceLocation(), _ expression: @autoclosure @escaping @Sendable () throws -> T?) -> SyncExpectation<T> {
    return SyncExpectation(
        expression: Expression(
            expression: expression,
            location: location,
            isClosure: true))
}

/// Make a ``SyncExpectation`` on a given actual value. The closure is lazily invoked.
/// This is provided as an alternative to `expect` which avoids overloading with `expect -> AsyncExpectation`.
public func expects<T>(location: SourceLocation = SourceLocation(), _ expression: @autoclosure () -> (@Sendable () throws -> T)) -> SyncExpectation<T> {
    return SyncExpectation(
        expression: Expression(
            expression: expression(),
            location: location,
            isClosure: true))
}

/// Make a ``SyncExpectation`` on a given actual value. The closure is lazily invoked.
/// This is provided as an alternative to `expect` which avoids overloading with `expect -> AsyncExpectation`.
public func expects<T>(location: SourceLocation = SourceLocation(), _ expression: @autoclosure () -> (@Sendable () throws -> T?)) -> SyncExpectation<T> {
    return SyncExpectation(
        expression: Expression(
            expression: expression(),
            location: location,
            isClosure: true))
}

/// Make a ``SyncExpectation`` on a given actual value. The closure is lazily invoked.
/// This is provided as an alternative to `expect` which avoids overloading with `expect -> AsyncExpectation`.
public func expects(location: SourceLocation = SourceLocation(), _ expression: @autoclosure () -> (@Sendable () throws -> Void)) -> SyncExpectation<Void> {
    // It would seem like `sending` isn't necessary for the `expression` argument
    // because the closure returns void. However, this gets rid of a type
    // conversion warning/error.
    return SyncExpectation(
        expression: Expression(
            expression: expression(),
            location: location,
            isClosure: true))
}

/// Always fails the test with a message and a specified location.
public func fail(_ message: String, location: SourceLocation = SourceLocation()) {
    let handler = NimbleEnvironment.activeInstance.assertionHandler
    handler.assert(false, message: FailureMessage(stringValue: message), location: location)
}

/// Always fails the test.
public func fail(location: SourceLocation = SourceLocation()) {
    fail("fail() always fails", location: location)
}

/// Like Swift's precondition(), but raises NSExceptions instead of sigaborts
internal func nimblePrecondition(
    _ expr: @autoclosure () -> Bool,
    _ name: @autoclosure () -> String,
    _ message: @autoclosure () -> String,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let result = expr()
    if !result {
        _nimblePrecondition(name(), message(), file, line)
    }
}

internal func internalError(_ msg: String, file: FileString = #filePath, line: UInt = #line) -> Never {
    fatalError(
        """
        Nimble Bug Found: \(msg) at \(file):\(line).
        Please file a bug to Nimble: https://github.com/Quick/Nimble/issues with the code snippet that caused this error.
        """
    )
}

#if canImport(Darwin)
import class Foundation.NSException
import struct Foundation.NSExceptionName

private func _nimblePrecondition(
    _ name: String,
    _ message: String,
    _ file: StaticString,
    _ line: UInt
) {
    let exception = NSException(
        name: NSExceptionName(name),
        reason: message,
        userInfo: nil
    )
    exception.raise()
}
#else
private func _nimblePrecondition(
    _ name: String,
    _ message: String,
    _ file: StaticString,
    _ line: UInt
) {
    preconditionFailure("\(name) - \(message)", file: file, line: line)
}
#endif
