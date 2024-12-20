#if !os(WASI)
import Dispatch
#endif

/// Make an ``AsyncExpectation`` on a given actual value. The value given is lazily evaluated.
public func expect<T: Sendable>(location: SourceLocation = SourceLocation(), _ expression: @escaping @Sendable () async throws -> T?) -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression,
            location: location,
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect<T: Sendable>(location: SourceLocation = SourceLocation(), _ expression: @Sendable () -> (@Sendable () async throws -> T)) -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression(),
            location: location,
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect<T: Sendable>(location: SourceLocation = SourceLocation(), _ expression: @Sendable () -> (@Sendable () async throws -> T?)) -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression(),
            location: location,
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
public func expect(location: SourceLocation = SourceLocation(), _ expression: @Sendable () -> (@Sendable () async throws -> Void)) -> AsyncExpectation<Void> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression(),
            location: location,
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The value given is lazily evaluated.
/// This is provided to avoid  confusion between `expect -> SyncExpectation` and `expect -> AsyncExpectation`.
public func expecta<T: Sendable>(location: SourceLocation = SourceLocation(), _ expression: @autoclosure @escaping @Sendable () async throws -> T?) async -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression,
            location: location,
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
/// This is provided to avoid  confusion between `expect -> SyncExpectation`  and `expect -> AsyncExpectation`
public func expecta<T: Sendable>(location: SourceLocation = SourceLocation(), _ expression: @autoclosure @Sendable () -> (@Sendable () async throws -> T)) async -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression(),
            location: location,
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
/// This is provided to avoid  confusion between `expect -> SyncExpectation`  and `expect -> AsyncExpectation`
public func expecta<T: Sendable>(location: SourceLocation = SourceLocation(), _ expression: @autoclosure @Sendable () -> (@Sendable () async throws -> T?)) async -> AsyncExpectation<T> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression(),
            location: location,
            isClosure: true))
}

/// Make an ``AsyncExpectation`` on a given actual value. The closure is lazily invoked.
/// This is provided to avoid  confusion between `expect -> SyncExpectation`  and `expect -> AsyncExpectation`
public func expecta(location: SourceLocation = SourceLocation(), _ expression: @autoclosure @Sendable () -> (@Sendable () async throws -> Void)) async -> AsyncExpectation<Void> {
    return AsyncExpectation(
        expression: AsyncExpression(
            expression: expression(),
            location: location,
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
    location: SourceLocation = SourceLocation(),
    action: @escaping @Sendable (@escaping @Sendable () -> Void) async -> Void
) async {
    await throwableUntil(
        timeout: timeout,
        sourceLocation: location
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
    location: SourceLocation = SourceLocation(),
    action: @escaping @Sendable (@escaping @Sendable () -> Void) -> Void
) async {
    await throwableUntil(
        timeout: timeout,
        sourceLocation: location
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
    action: @escaping @Sendable (@escaping @Sendable () -> Void) async throws -> Void) async {
        let leeway = timeout.divided
        let result = await performBlock(
            timeoutInterval: timeout,
            leeway: leeway,
            sourceLocation: sourceLocation) { @MainActor (done: @escaping @Sendable (ErrorResult) -> Void) async throws -> Void in
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
                location: sourceLocation
            )
        case .timedOut:
            fail(
                "Waited more than \(timeout.description)",
                location: sourceLocation
            )
        case let .errorThrown(error):
            fail(
                "Unexpected error thrown: \(error)",
                location: sourceLocation
            )
        case .completed(.error(let error)):
            fail(
                "Unexpected error thrown: \(error)",
                location: sourceLocation
            )
        case .completed(.none): // success
            break
        }
}

#endif // #if !os(WASI)
