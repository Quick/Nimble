/// Make a ``SyncRequirement`` on a given actual value. The value given is lazily evaluated.
public func require<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure @escaping () throws -> T?) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression,
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make a ``SyncRequirement`` on a given actual value. The closure is lazily invoked.
public func require<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure () -> (() throws -> T)) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make a ``SyncRequirement`` on a given actual value. The closure is lazily invoked.
public func require<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure () -> (() throws -> T?)) -> SyncRequirement<T> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make a ``SyncRequirement`` on a given actual value. The closure is lazily invoked.
public func require(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure () -> (() throws -> Void)) -> SyncRequirement<Void> {
    return SyncRequirement(
        expression: Expression(
            expression: expression(),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make an ``AsyncRequirement`` on a given actual value. The value given is lazily evaluated.
public func require<T>(file: FileString = #file, line: UInt = #line, _ expression: @escaping () async throws -> T?) -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression,
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make an ``AsyncRequirement`` on a given actual value. The closure is lazily invoked.
public func require<T>(file: FileString = #file, line: UInt = #line, _ expression: () -> (() async throws -> T)) -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression(),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make an ``AsyncRequirement`` on a given actual value. The closure is lazily invoked.
public func require<T>(file: FileString = #file, line: UInt = #line, _ expression: () -> (() async throws -> T?)) -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression(),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make an ``AsyncRequirement`` on a given actual value. The value given is lazily evaluated.
/// This is provided to avoid  confusion between `require -> SyncRequirement` and `erequire -> AsyncRequirement`.
public func requireAsync<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure @escaping () async throws -> T?) async -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression,
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make an ``AsyncRequirement`` on a given actual value. The closure is lazily invoked.
/// This is provided to avoid  confusion between `require -> SyncRequirement`  and `require -> AsyncRequirement`
public func requireAsync<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure () -> (() async throws -> T)) async -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression(),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make an ``AsyncRequirement`` on a given actual value. The closure is lazily invoked.
/// This is provided to avoid  confusion between `require -> SyncRequirement`  and `require -> AsyncRequirement`
public func requireAsync<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure () -> (() async throws -> T?)) async -> AsyncRequirement<T> {
    return AsyncRequirement(
        expression: AsyncExpression(
            expression: expression(),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

// MARK: - Unwrap

/// Makes sure that the expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `require(expression).toNot(beNil())`
public func unwrap<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure @escaping () throws -> T?) throws -> T {
    try require(file: file, line: line, expression()).toNot(beNil())
}

/// Makes sure that the expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `require(expression).toNot(beNil())`
@discardableResult
public func unwrap<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure () -> (() throws -> T?)) throws -> T {
    try require(file: file, line: line, expression()).toNot(beNil())
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requireAsync(expression).toNot(beNil())`
public func unwrap<T>(file: FileString = #file, line: UInt = #line, _ expression: @escaping () async throws -> T?) async throws -> T {
    try await requireAsync(file: file, line: line, try await expression()).toNot(beNil())
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requireAsync(expression).toNot(beNil())`
@discardableResult
public func unwrap<T>(file: FileString = #file, line: UInt = #line, _ expression: () -> (() async throws -> T?)) async throws -> T {
    try await requireAsync(file: file, line: line, expression()).toNot(beNil())
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requireAsync(expression).toNot(beNil())`
public func unwrapAsync<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure @escaping () async throws -> T?) async throws -> T {
    try await requireAsync(file: file, line: line, try await expression()).toNot(beNil())
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requireAsync(expression).toNot(beNil())`
@discardableResult
public func unwrapAsync<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure () -> (() async throws -> T?)) async throws -> T {
    try await requireAsync(file: file, line: line, expression()).toNot(beNil())
}
