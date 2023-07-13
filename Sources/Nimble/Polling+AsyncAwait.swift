#if !os(WASI)

import Dispatch

@MainActor
private func execute<T>(_ expression: AsyncExpression<T>, style: ExpectationStyle, to: String, description: String?, predicateExecutor: () async throws -> PredicateResult) async -> (Bool, FailureMessage) {
    let msg = FailureMessage()
    msg.userDescription = description
    msg.to = to
    do {
        let result = try await predicateExecutor()
        result.message.update(failureMessage: msg)
        if msg.actualValue == "" {
            msg.actualValue = "<\(stringify(try await expression.evaluate()))>"
        }
        return (result.toBoolean(expectation: style), msg)
    } catch let error {
        msg.stringValue = "unexpected error thrown: <\(error)>"
        return (false, msg)
    }
}

private actor Poller<T> {
     private var lastPredicateResult: PredicateResult?

     init() {}

     func poll(expression: AsyncExpression<T>,
               style: ExpectationStyle,
               matchStyle: AsyncMatchStyle,
               timeout: NimbleTimeInterval,
               poll: NimbleTimeInterval,
               fnName: String,
               predicateRunner: @escaping () async throws -> PredicateResult) async -> PredicateResult {
         let fnName = "expect(...).\(fnName)(...)"
         let result = await pollBlock(
             pollInterval: poll,
             timeoutInterval: timeout,
             file: expression.location.file,
             line: expression.location.line,
             fnName: fnName) {
                 self.updatePredicateResult(result: try await predicateRunner())
                     .toBoolean(expectation: style)
             }
         return processPollResult(result, matchStyle: matchStyle, lastPredicateResult: lastPredicateResult, fnName: fnName)
     }

     func updatePredicateResult(result: PredicateResult) -> PredicateResult {
         self.lastPredicateResult = result
         return result
     }
 }

// swiftlint:disable:next function_parameter_count
private func poll<T>(
    expression: AsyncExpression<T>,
    style: ExpectationStyle,
    matchStyle: AsyncMatchStyle,
    timeout: NimbleTimeInterval,
    poll: NimbleTimeInterval,
    fnName: String,
    predicateRunner: @escaping () async throws -> PredicateResult
) async -> PredicateResult {
    let poller = Poller<T>()
    return await poller.poll(
        expression: expression,
        style: style,
        matchStyle: matchStyle,
        timeout: timeout,
        poll: poll,
        fnName: fnName,
        predicateRunner: predicateRunner
    )
}

extension SyncExpectation {
    // MARK: - With Synchronous Predicates
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventually(_ predicate: Predicate<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toMatch,
            to: "to eventually",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toMatch,
                    matchStyle: .eventually,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventually") { @MainActor in
                        try predicate.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventuallyNot(_ predicate: Predicate<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toNotMatch,
            to: "to eventually not",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toNotMatch,
                    matchStyle: .eventually,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventuallyNot") { @MainActor in
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
    public func toNotEventually(_ predicate: Predicate<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toEventuallyNot(predicate, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toNever(_ predicate: Predicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)
        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toNotMatch,
            to: "to never",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toMatch,
                    matchStyle: .never,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toNever") { @MainActor in
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
    public func neverTo(_ predicate: Predicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toNever(predicate, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    @discardableResult
    public func toAlways(_ predicate: Predicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)
        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toMatch,
            to: "to always",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toNotMatch,
                    matchStyle: .always,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toAlways") { @MainActor in
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
    public func alwaysTo(_ predicate: Predicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toAlways(predicate, until: until, pollInterval: pollInterval, description: description)
    }

    // MARK: - With AsyncPredicates
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventually(_ predicate: AsyncPredicate<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toMatch,
            to: "to eventually",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toMatch,
                    matchStyle: .eventually,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventually") { @MainActor in
                        try await predicate.satisfies(expression.withoutCaching().toAsyncExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventuallyNot(_ predicate: AsyncPredicate<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toNotMatch,
            to: "to eventually not",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toNotMatch,
                    matchStyle: .eventually,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventuallyNot") { @MainActor in
                        try await predicate.satisfies(expression.withoutCaching().toAsyncExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    @discardableResult
    public func toNotEventually(_ predicate: AsyncPredicate<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toEventuallyNot(predicate, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toNever(_ predicate: AsyncPredicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)
        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toNotMatch,
            to: "to never",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toMatch,
                    matchStyle: .never,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toNever") { @MainActor in
                        try await predicate.satisfies(expression.withoutCaching().toAsyncExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    @discardableResult
    public func neverTo(_ predicate: AsyncPredicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toNever(predicate, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    @discardableResult
    public func toAlways(_ predicate: AsyncPredicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)
        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toMatch,
            to: "to always",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toNotMatch,
                    matchStyle: .always,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toAlways") { @MainActor in
                        try await predicate.satisfies(expression.withoutCaching().toAsyncExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    @discardableResult
    public func alwaysTo(_ predicate: AsyncPredicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toAlways(predicate, until: until, pollInterval: pollInterval, description: description)
    }
}

extension AsyncExpectation {
    // MARK: - With Synchronous Predicates
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventually(_ predicate: Predicate<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
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
                        try predicate.satisfies(await expression.withoutCaching().toSynchronousExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventuallyNot(_ predicate: Predicate<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
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
                        try predicate.satisfies(await expression.withoutCaching().toSynchronousExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    @discardableResult
    public func toNotEventually(_ predicate: Predicate<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toEventuallyNot(predicate, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toNever(_ predicate: Predicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
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
                        try predicate.satisfies(await expression.withoutCaching().toSynchronousExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    @discardableResult
    public func neverTo(_ predicate: Predicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toNever(predicate, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    @discardableResult
    public func toAlways(_ predicate: Predicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
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
                        try predicate.satisfies(await expression.withoutCaching().toSynchronousExpression())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    @discardableResult
    public func alwaysTo(_ predicate: Predicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toAlways(predicate, until: until, pollInterval: pollInterval, description: description)
    }

    // MARK: - With AsyncPredicates
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventually(_ predicate: AsyncPredicate<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
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
                        try await predicate.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventuallyNot(_ predicate: AsyncPredicate<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
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
                        try await predicate.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    @discardableResult
    public func toNotEventually(_ predicate: AsyncPredicate<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toEventuallyNot(predicate, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toNever(_ predicate: AsyncPredicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
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
                        try await predicate.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    @discardableResult
    public func neverTo(_ predicate: AsyncPredicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toNever(predicate, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    @discardableResult
    public func toAlways(_ predicate: AsyncPredicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
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
                        try await predicate.satisfies(expression.withoutCaching())
                    }
            }
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    @discardableResult
    public func alwaysTo(_ predicate: AsyncPredicate<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async -> Self {
        return await toAlways(predicate, until: until, pollInterval: pollInterval, description: description)
    }
}

#endif // #if !os(WASI)
