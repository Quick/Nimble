#if !os(WASI)
import Dispatch
#endif

/// Make an ``AsyncExpectation`` on a given actual value. The value given is lazily evaluated.
public func expect<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, _ expression: @escaping () async throws -> T?) -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression,
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, _ expression: () -> (() async throws -> T)) -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, _ expression: () -> (() async throws -> T?)) -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, _ expression: () -> (() async throws -> Void)) -> AsyncExpectation<Void> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The value given is lazily evaluated.
/// This is provided to avoid  confusion between `expect -> SyncExpectation` and `expect -> AsyncExpectation`.
public func expecta<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, _ expression: @autoclosure @escaping () async throws -> T?) async -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression,
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
/// This is provided to avoid  confusion between `expect -> SyncExpectation`  and `expect -> AsyncExpectation`
public func expecta<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, _ expression: @autoclosure () -> (() async throws -> T)) async -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
/// This is provided to avoid  confusion between `expect -> SyncExpectation`  and `expect -> AsyncExpectation`
public func expecta<T>(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, _ expression: @autoclosure () -> (() async throws -> T?)) async -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
/// This is provided to avoid  confusion between `expect -> SyncExpectation`  and `expect -> AsyncExpectation`
public func expecta(fileID: String = #fileID, file: FileString = #filePath, line: UInt = #line, column: UInt = #column, _ expression: @autoclosure () -> (() async throws -> Void)) async -> AsyncExpectation<Void> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression(),
            location: SourceLocation(fileID: fileID, filePath: file, line: line, column: column),
            isClosure: true))
}

#if !os(WASI)

/// Wait asynchronously until the done closure is called or the timeout has been reached.
///
/// @discussion
/// Call the done() closure to indicate the waiting has completed.
///
/// @warning
/// Unlike the synchronous version of this call, this does not support catching Objective-C exceptions.
public func waitUntil(
    timeout: NimbleTimeInterval = PollingDefaults.timeout,
    fileID: String = #fileID,
    file: FileString = #filePath,
    line: UInt = #line,
    column: UInt = #column,
    action: @escaping (@escaping () -> Void) async -> Void
) async {
    await throwableUntil(
        timeout: timeout,
        sourceLocation: SourceLocation(fileID: fileID, filePath: file, line: line, column: column)
    ) { done in
        await action(done)
    }
}

/// Wait asynchronously until the done closure is called or the timeout has been reached.
///
/// @discussion
/// Call the done() closure to indicate the waiting has completed.
///
/// @warning
/// Unlike the synchronous version of this call, this does not support catching Objective-C exceptions.
public func waitUntil(
    timeout: NimbleTimeInterval = PollingDefaults.timeout,
    fileID: String = #fileID,
    file: FileString = #filePath,
    line: UInt = #line,
    column: UInt = #column,
    action: @escaping (@escaping () -> Void) -> Void
) async {
    await throwableUntil(
        timeout: timeout,
        sourceLocation: SourceLocation(fileID: fileID, filePath: file, line: line, column: column)
    ) { done in
        action(done)
    }
}

private enum ErrorResult {
    case error(Error)
    case none
}

private func throwableUntil(
    timeout: NimbleTimeInterval,
    sourceLocation: SourceLocation,
    action: @escaping (@escaping () -> Void) async throws -> Void) async {
        let leeway = timeout.divided
        let result = await performBlock(
            timeoutInterval: timeout,
            leeway: leeway,
            sourceLocation: sourceLocation) { @MainActor (done: @escaping (ErrorResult) -> Void) async throws -> Void in
                do {
                    try await action {
                        done(.none)
                    }
                } catch let e {
                    done(.error(e))
                }
            }

        switch result {
        case .incomplete: internalError("Reached .incomplete state for waitUntil(...).")
        case .blockedRunLoop:
            fail(
                blockedRunLoopErrorMessageFor("-waitUntil()", leeway: leeway),
                fileID: sourceLocation.fileID,
                file: sourceLocation.filePath,
                line: sourceLocation.line,
                column: sourceLocation.column
            )
        case .timedOut:
            fail(
                "Waited more than \(timeout.description)",
                fileID: sourceLocation.fileID,
                file: sourceLocation.filePath,
                line: sourceLocation.line,
                column: sourceLocation.column
            )
        case let .errorThrown(error):
            fail(
                "Unexpected error thrown: \(error)",
                fileID: sourceLocation.fileID,
                file: sourceLocation.filePath,
                line: sourceLocation.line,
                column: sourceLocation.column
            )
        case .completed(.error(let error)):
            fail(
                "Unexpected error thrown: \(error)",
                fileID: sourceLocation.fileID,
                file: sourceLocation.filePath,
                line: sourceLocation.line,
                column: sourceLocation.column
            )
        case .completed(.none): // success
            break
        }
}

#endif // #if !os(WASI)
