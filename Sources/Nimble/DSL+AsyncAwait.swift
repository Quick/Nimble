private func convertAsyncExpression<T>(_ asyncExpression: () async throws -> T) async -> (() throws -> T) {
    let result: Result<T, Error>
    do {
        result = .success(try await asyncExpression())
    } catch {
        result = .failure(error)
    }
    return { try result.get() }
}

/// Make an ``AsyncExpectation`` on a given actual value. The value given is lazily evaluated.
public func expect<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure @escaping () async throws -> T?) async -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: Expression(
            expression: await convertAsyncExpression(expression),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure () -> (() async throws -> T)) async -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: Expression(
            expression: await convertAsyncExpression(expression()),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure () -> (() async throws -> T?)) async -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: Expression(
            expression: await convertAsyncExpression(expression()),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure () -> (() async throws -> Void)) async -> AsyncExpectation<Void> {
    return AsyncExpectation(
        expression: Expression(
            expression: await convertAsyncExpression(expression()),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}
