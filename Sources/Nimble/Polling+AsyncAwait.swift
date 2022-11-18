import Dispatch

@MainActor
private func execute<T>(_ expression: Expression<T>, style: ExpectationStyle, to: String, description: String?, predicateExecutor: () async throws -> PredicateResult) async -> (Bool, FailureMessage) {
    let msg = FailureMessage()
    msg.userDescription = description
    msg.to = to
    do {
        let result = try await predicateExecutor()
        result.message.update(failureMessage: msg)
        if msg.actualValue == "" {
            msg.actualValue = "<\(stringify(try expression.evaluate()))>"
        }
        return (result.toBoolean(expectation: style), msg)
    } catch let error {
        msg.stringValue = "unexpected error thrown: <\(error)>"
        return (false, msg)
    }
}

// swiftlint:disable:next function_parameter_count
private func poll<T>(
    expression: Expression<T>,
    style: ExpectationStyle,
    matchStyle: AsyncMatchStyle,
    timeout: DispatchTimeInterval,
    poll: DispatchTimeInterval,
    fnName: String,
    predicateRunner: @escaping () throws -> PredicateResult
) async -> PredicateResult {
    let fnName = "expect(...).\(fnName)(...)"
    var lastPredicateResult: PredicateResult?
    let result = await pollBlock(
        pollInterval: poll,
        timeoutInterval: timeout,
        file: expression.location.file,
        line: expression.location.line,
        fnName: fnName) {
            lastPredicateResult = try predicateRunner()
            return lastPredicateResult!.toBoolean(expectation: style)
        }
    return processPollResult(result, matchStyle: matchStyle, lastPredicateResult: lastPredicateResult, fnName: fnName)
}

extension SyncExpectation {
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventually(_ predicate: Predicate<Value>, timeout: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toMatch,
            to: "to eventually",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toMatch,
                    matchStyle: .eventually,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventually") {
                        try predicate.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventuallyNot(_ predicate: Predicate<Value>, timeout: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toNotMatch,
            to: "to eventually not",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toNotMatch,
                    matchStyle: .eventually,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventuallyNot") {
                        try predicate.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    @discardableResult
    public func toNotEventually(_ predicate: Predicate<Value>, timeout: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toEventuallyNot(predicate, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toNever(_ predicate: Predicate<Value>, until: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toNotMatch,
            to: "to never",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toMatch,
                    matchStyle: .never,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toNever") {
                        try predicate.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    @discardableResult
    public func neverTo(_ predicate: Predicate<Value>, until: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toNever(predicate, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    @discardableResult
    public func toAlways(_ predicate: Predicate<Value>, until: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toMatch,
            to: "to always",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toNotMatch,
                    matchStyle: .always,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toAlways") {
                        try predicate.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    @discardableResult
    public func alwaysTo(_ predicate: Predicate<Value>, until: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toAlways(predicate, until: until, pollInterval: pollInterval, description: description)
    }
}
