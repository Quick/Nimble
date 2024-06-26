/// Make a ``SyncRequirement`` on a given actual value. The value given is lazily evaluated.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func require<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure @escaping () throws -> T?) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression,
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
            isClosure: true),
        customError: customError)
}

/// Make a ``SyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func require<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure () -> (() throws -> T)) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
            isClosure: true),
        customError: customError)
}

/// Make a ``SyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func require<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure () -> (() throws -> T?)) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
            isClosure: true),
        customError: customError)
}

/// Make a ``SyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func require(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure () -> (() throws -> Void)) -> SyncRequirement<Void> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
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
public func requires<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure @escaping () throws -> T?) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression,
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
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
public func requires<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure () -> (() throws -> T)) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
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
public func requires<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure () -> (() throws -> T?)) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
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
public func requires(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure () -> (() throws -> Void)) -> SyncRequirement<Void> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
            isClosure: true),
        customError: customError)
}

/// Make an ``AsyncRequirement`` on a given actual value. The value given is lazily evaluated.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func require<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @escaping () async throws -> T?) -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression,
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
            isClosure: true),
        customError: customError)
}

/// Make an ``AsyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func require<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: () -> (() async throws -> T)) -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
            isClosure: true),
        customError: customError)
}

/// Make an ``AsyncRequirement`` on a given actual value. The closure is lazily invoked.
///
/// `require` will return the result of the expression if the matcher passes, and throw an error if not.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func require<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: () -> (() async throws -> T?)) -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
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
public func requirea<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure @escaping () async throws -> T?) async -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression,
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
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
public func requirea<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure () -> (() async throws -> T)) async -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
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
public func requirea<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure () -> (() async throws -> T?)) async -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
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
public func unwrap<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure @escaping () throws -> T?) throws -> T {
    try requires(fileID: fileID, file: file, line: line, column: column, customError: customError, expression()).toNot(beNil())
}

/// Makes sure that the expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `require(expression).toNot(beNil())`.
///
/// `unwrap` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwrap<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure () -> (() throws -> T?)) throws -> T {
    try requires(fileID: fileID, file: file, line: line, column: column, customError: customError, expression()).toNot(beNil())
}

/// Makes sure that the expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `require(expression).toNot(beNil())`.
///
/// `unwraps` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwraps<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure @escaping () throws -> T?) throws -> T {
    try requires(fileID: fileID, file: file, line: line, column: column, customError: customError, expression()).toNot(beNil())
}

/// Makes sure that the expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `require(expression).toNot(beNil())`.
///
/// `unwraps` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwraps<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure () -> (() throws -> T?)) throws -> T {
    try requires(fileID: fileID, file: file, line: line, column: column, customError: customError, expression()).toNot(beNil())
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requirea(expression).toNot(beNil())`.
///
/// `unwrap` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwrap<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @escaping () async throws -> T?) async throws -> T {
    try await requirea(fileID: fileID, file: file, line: line, column: column, customError: customError, try await expression()).toNot(beNil())
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requirea(expression).toNot(beNil())`.
///
/// `unwrap` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwrap<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: () -> (() async throws -> T?)) async throws -> T {
    try await requirea(fileID: fileID, file: file, line: line, column: column, customError: customError, expression()).toNot(beNil())
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requirea(expression).toNot(beNil())`.
///
/// `unwrapa` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwrapa<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure @escaping () async throws -> T?) async throws -> T {
    try await requirea(fileID: fileID, file: file, line: line, column: column, customError: customError, try await expression()).toNot(beNil())
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requirea(expression).toNot(beNil())`.
///
/// `unwrapa` will return the result of the expression if it is non-nil, and throw an error if the value is nil.
/// if a `customError` is given, then that will be thrown. Otherwise, a ``RequireError`` will be thrown.
@discardableResult
public func unwrapa<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, customError: Error? = nil, _ expression: @autoclosure () -> (() async throws -> T?)) async throws -> T {
    try await requirea(fileID: fileID, file: file, line: line, column: column, customError: customError, expression()).toNot(beNil())
}
