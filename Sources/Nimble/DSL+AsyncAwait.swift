import Dispatch

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
public func expect<T>(file: FileString = #file, line: UInt = #line, _ expression: @escaping () async throws -> T?) async -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: Expression(
            expression: await convertAsyncExpression(expression),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect<T>(file: FileString = #file, line: UInt = #line, _ expression: () -> (() async throws -> T)) async -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: Expression(
            expression: await convertAsyncExpression(expression()),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect<T>(file: FileString = #file, line: UInt = #line, _ expression: () -> (() async throws -> T?)) async -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: Expression(
            expression: await convertAsyncExpression(expression()),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect(file: FileString = #file, line: UInt = #line, _ expression: () -> (() async throws -> Void)) async -> AsyncExpectation<Void> {
    return AsyncExpectation(
        expression: Expression(
            expression: await convertAsyncExpression(expression()),
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Wait asynchronously until the done closure is called or the timeout has been reached.
///
/// @discussion
/// Call the done() closure to indicate the waiting has completed.
///
/// @warning
/// Unlike the synchronous version of this call, this does not support catching Objective-C exceptions.
public func waitUntil(timeout: DispatchTimeInterval = AsyncDefaults.timeout, file: FileString = #file, line: UInt = #line, action: @escaping (@escaping () -> Void) async -> Void) async {
    await throwableUntil(timeout: timeout) { done in
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
public func waitUntil(timeout: DispatchTimeInterval = AsyncDefaults.timeout, file: FileString = #file, line: UInt = #line, action: @escaping (@escaping () -> Void) -> Void) async {
    await throwableUntil(timeout: timeout, file: file, line: line) { done in
        action(done)
    }
}

private enum ErrorResult {
    case error(Error)
    case none
}

private func throwableUntil(
    timeout: DispatchTimeInterval,
    file: FileString = #file,
    line: UInt = #line,
    action: @escaping (@escaping () -> Void) async throws -> Void) async {
        let awaiter = NimbleEnvironment.activeInstance.awaiter
        let leeway = timeout.divided
        let result = await awaiter.performBlock(file: file, line: line) { @MainActor (done: @escaping (ErrorResult) -> Void) async throws -> Void in
            do {
                try await action {
                    done(.none)
                }
            } catch let e {
                done(.error(e))
            }
        }
            .timeout(timeout, forcefullyAbortTimeout: leeway)
            .wait("waitUntil(...)", file: file, line: line)

        switch result {
        case .incomplete: internalError("Reached .incomplete state for waitUntil(...).")
        case .blockedRunLoop:
            fail(blockedRunLoopErrorMessageFor("-waitUntil()", leeway: leeway),
                 file: file, line: line)
        case .timedOut:
            fail("Waited more than \(timeout.description)", file: file, line: line)
        case let .raisedException(exception):
            fail("Unexpected exception raised: \(exception)")
        case let .errorThrown(error):
            fail("Unexpected error thrown: \(error)")
        case .completed(.error(let error)):
            fail("Unexpected error thrown: \(error)")
        case .completed(.none): // success
            break
        }
}
