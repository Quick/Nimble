/// Make a ``SyncRequirement`` on a given actual value. The value given is lazily evaluated.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func require<T>(location: SourceLocation = SourceLocation(), customError: Error? = nil, _ expression: @autoclosure @escaping @Sendable () throws -> T?) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression,
            location: location,
            isClosure: true),
        customError: customError)
}

/// Make a ``SyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func require<T>(location: SourceLocation = SourceLocation(), customError: Error? = nil, _ expression: @autoclosure () -> (@Sendable () throws -> T)) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: location,
            isClosure: true),
        customError: customError)
}

/// Make a ``SyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func require<T>(location: SourceLocation = SourceLocation(), customError: Error? = nil, _ expression: @autoclosure () -> (@Sendable () throws -> T?)) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: location,
            isClosure: true),
        customError: customError)
}

/// Make a ``SyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func require(location: SourceLocation = SourceLocation(), customError: Error? = nil, _ expression: @autoclosure () -> (@Sendable () throws -> Void)) -> SyncRequirement<Void> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: location,
            isClosure: true),
        customError: customError)
}

/// Make a ``SyncRequirement`` on a given actual value. The value given is lazily evaluated.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
///
/// This is provided as an alternative to ``require``, for when you want to be specific about whether you're using ``SyncRequirement`` or ``AsyncRequirement``.
@discardableResult
public func requires<T>(location: SourceLocation = SourceLocation(), customError: Error? = nil, _ expression: @autoclosure @escaping @Sendable () throws -> T?) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression,
            location: location,
            isClosure: true),
        customError: customError)
}

/// Make a ``SyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
///
/// This is provided as an alternative to ``require``, for when you want to be specific about whether you're using ``SyncRequirement`` or ``AsyncRequirement``.
@discardableResult
public func requires<T>(location: SourceLocation = SourceLocation(), customError: Error? = nil, _ expression: @autoclosure () -> (@Sendable () throws -> T)) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: location,
            isClosure: true),
        customError: customError)
}

/// Make a ``SyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
///
/// This is provided as an alternative to ``require``, for when you want to be specific about whether you're using ``SyncRequirement`` or ``AsyncRequirement``.
@discardableResult
public func requires<T>(location: SourceLocation = SourceLocation(), customError: Error? = nil, _ expression: @autoclosure () -> (@Sendable () throws -> T?)) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: location,
            isClosure: true),
        customError: customError)
}

/// Make a ``SyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
///
/// This is provided as an alternative to ``require``, for when you want to be specific about whether you're using ``SyncRequirement`` or ``AsyncRequirement``.
@discardableResult
public func requires(location: SourceLocation = SourceLocation(), customError: Error? = nil, _ expression: @autoclosure () -> (@Sendable () throws -> Void)) -> SyncRequirement<Void> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: location,
            isClosure: true),
        customError: customError)
}

/// Make an ``AsyncRequirement`` on a given actual value. The value given is lazily evaluated.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func require<T: Sendable>(location: SourceLocation = SourceLocation(), customError: Error? = nil, _ expression: @escaping @Sendable () async throws -> T?) -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression,
            location: location,
            isClosure: true),
        customError: customError)
}

/// Make an ``AsyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func require<T: Sendable>(location: SourceLocation = SourceLocation(), customError: Error? = nil, _ expression: () -> (@Sendable () async throws -> T)) -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression(),
            location: location,
            isClosure: true),
        customError: customError)
}

/// Make an ``AsyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func require<T: Sendable>(location: SourceLocation = SourceLocation(), customError: Error? = nil, _ expression: () -> (@Sendable () async throws -> T?)) -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression(),
            location: location,
            isClosure: true),
        customError: customError)
}

/// Make an ``AsyncRequirement`` on a given actual value. The value given is lazily evaluated.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
///
/// This is provided to avoid  confusion between `require -> SyncRequirement` and `require -> AsyncRequirement`.
@discardableResult
public func requirea<T: Sendable>(location: SourceLocation = SourceLocation(), customError: Error? = nil, _ expression: @autoclosure @escaping @Sendable () async throws -> T?) async -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression,
            location: location,
            isClosure: true),
        customError: customError)
}

/// Make an ``AsyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
///
/// This is provided to avoid  confusion between `require -> SyncRequirement`  and `require -> AsyncRequirement`
@discardableResult
public func requirea<T: Sendable>(location: SourceLocation = SourceLocation(), customError: Error? = nil, _ expression: @autoclosure () -> (@Sendable () async throws -> T)) async -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression(),
            location: location,
            isClosure: true),
        customError: customError)
}

/// Make an ``AsyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
///
/// This is provided to avoid  confusion between `require -> SyncRequirement`  and `require -> AsyncRequirement`
@discardableResult
public func requirea<T: Sendable>(location: SourceLocation = SourceLocation(), customError: Error? = nil, _ expression: @autoclosure () -> (@Sendable () async throws -> T?)) async -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression(),
            location: location,
            isClosure: true),
        customError: customError)
}

// MARK: - Unwrap

/// Makes sure that the expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `require(expression).toNot(beNil())`.
///
/// `unwrap` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwrap<T>(location: SourceLocation = SourceLocation(), customError: Error? = nil, description: String? = nil, _ expression: @autoclosure @escaping @Sendable () throws -> T?) throws -> T {
    try requires(location: location, customError: customError, expression()).toNot(beNil(), description: description)
}

/// Makes sure that the expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `require(expression).toNot(beNil())`.
///
/// `unwrap` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwrap<T>(location: SourceLocation = SourceLocation(), customError: Error? = nil, description: String? = nil, _ expression: @autoclosure () -> (@Sendable () throws -> T?)) throws -> T {
    try requires(location: location, customError: customError, expression()).toNot(beNil(), description: description)
}

/// Makes sure that the expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `require(expression).toNot(beNil())`.
///
/// `unwraps` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwraps<T>(location: SourceLocation = SourceLocation(), customError: Error? = nil, description: String? = nil, _ expression: @autoclosure @escaping @Sendable () throws -> T?) throws -> T {
    try requires(location: location, customError: customError, expression()).toNot(beNil(), description: description)
}

/// Makes sure that the expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `require(expression).toNot(beNil())`.
///
/// `unwraps` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwraps<T>(location: SourceLocation = SourceLocation(), customError: Error? = nil, description: String? = nil, _ expression: @autoclosure () -> (@Sendable () throws -> T?)) throws -> T {
    try requires(location: location, customError: customError, expression()).toNot(beNil(), description: description)
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requirea(expression).toNot(beNil())`.
///
/// `unwrap` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwrap<T: Sendable>(location: SourceLocation = SourceLocation(), customError: Error? = nil, description: String? = nil, _ expression: @escaping () async throws -> T?) async throws -> T {
    try await requirea(location: location, customError: customError, try await expression()).toNot(beNil(), description: description)
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requirea(expression).toNot(beNil())`.
///
/// `unwrap` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwrap<T: Sendable>(location: SourceLocation = SourceLocation(), customError: Error? = nil, description: String? = nil, _ expression: () -> (@Sendable () async throws -> T?)) async throws -> T {
    try await requirea(location: location, customError: customError, expression()).toNot(beNil(), description: description)
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requirea(expression).toNot(beNil())`.
///
/// `unwrapa` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwrapa<T: Sendable>(location: SourceLocation = SourceLocation(), customError: Error? = nil, description: String? = nil, _ expression: @autoclosure @escaping () async throws -> T?) async throws -> T {
    try await requirea(location: location, customError: customError, try await expression()).toNot(beNil(), description: description)
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requirea(expression).toNot(beNil())`.
///
/// `unwrapa` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwrapa<T: Sendable>(location: SourceLocation = SourceLocation(), customError: Error? = nil, description: String? = nil, _ expression: @autoclosure () -> (@Sendable () async throws -> T?)) async throws -> T {
    try await requirea(location: location, customError: customError, expression()).toNot(beNil(), description: description)
}

/// Always fails the test and throw an error to prevent further test execution.
///
/// - Parameter message: A custom message to use in place of the default one.
/// - Parameter customError: A custom error to throw in place of a ``RequireError``.
public func requireFail(_ message: String? = nil, customError: Error? = nil, location: SourceLocation = SourceLocation()) throws {
    let handler = NimbleEnvironment.activeInstance.assertionHandler

    let msg = message ?? "requireFail() always fails"
    handler.assert(false, message: FailureMessage(stringValue: msg), location: location)

    throw customError ?? RequireError(message: msg, location: location)
}
