// swiftlint:disable file_length
#if !os(WASI)

import Dispatch

extension SyncRequirement {
    // MARK: - Dispatch Polling with Synchronous Matchers
    /// Require the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    ///
    /// @warning
    /// This form of `toEventually` does not work in any kind of async context. Use the async form of `toEventually` if you are running tests in an async context.
    @available(*, noasync, message: "the sync variant of `toEventually` does not work in async contexts. Use the async variant as a drop-in replacement")
    @discardableResult
    public func toEventually(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) throws -> Value {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = execute(
            expression,
            .toMatch,
            poll(
                style: .toMatch,
                matchStyle: .eventually,
                matcher: matcher,
                timeout: timeout,
                poll: pollInterval,
                fnName: "toEventually"
            ),
            to: "to eventually",
            description: description,
            captureExceptions: false
        )
        return try verify(pass, msg, try expression.evaluate())
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    ///
    /// @warning
    /// This form of `toEventuallyNot` does not work in any kind of async context.
    /// Use the async form of `toEventuallyNot` if you are running tests in an async context.
    @available(*, noasync, message: "the sync variant of `toEventuallyNot` does not work in async contexts. Use the async variant as a drop-in replacement")
    @discardableResult
    public func toEventuallyNot(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) throws -> Value {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = execute(
            expression,
            .toNotMatch,
            poll(
                style: .toNotMatch,
                matchStyle: .eventually,
                matcher: matcher,
                timeout: timeout,
                poll: pollInterval,
                fnName: "toEventuallyNot"
            ),
            to: "to eventually not",
            description: description,
            captureExceptions: false
        )
        return try verify(pass, msg, try expression.evaluate())
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    ///
    /// @warning
    /// This form of `toNotEventually` does not work in any kind of async context.
    /// Use the async form of `toNotEventually` if you are running tests in an async context.
    @available(*, noasync, message: "the sync variant of `toNotEventually` does not work in async contexts. Use the async variant as a drop-in replacement")
    @discardableResult
    public func toNotEventually(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) throws -> Value {
        return try toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    ///
    /// @warning
    /// This form of `toNever` does not work in any kind of async context.
    /// Use the async form of `toNever` if you are running tests in an async context.
    @available(*, noasync, message: "the sync variant of `toNever` does not work in async contexts. Use the async variant as a drop-in replacement")
    @discardableResult
    public func toNever(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) throws -> Value {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = execute(
            expression,
            .toNotMatch,
            poll(
                style: .toNotMatch,
                matchStyle: .never,
                matcher: matcher,
                timeout: until,
                poll: pollInterval,
                fnName: "toNever"
            ),
            to: "to never",
            description: description,
            captureExceptions: false
        )
        return try verify(pass, msg, try expression.evaluate())
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    ///
    /// @warning
    /// This form of `neverTo` does not work in any kind of async context.
    /// Use the async form of `neverTo` if you are running tests in an async context.
    @available(*, noasync, message: "the sync variant of `neverTo` does not work in async contexts. Use the async variant as a drop-in replacement")
    @discardableResult
    public func neverTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) throws -> Value {
        return try toNever(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    ///
    /// @warning
    /// This form of `toAlways` does not work in any kind of async context.
    /// Use the async form of `toAlways` if you are running tests in an async context.
    @available(*, noasync, message: "the sync variant of `toAlways` does not work in async contexts. Use the async variant as a drop-in replacement")
    @discardableResult
    public func toAlways(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) throws -> Value {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = execute(
            expression,
            .toMatch,
            poll(
                style: .toMatch,
                matchStyle: .always,
                matcher: matcher,
                timeout: until,
                poll: pollInterval,
                fnName: "toAlways"
            ),
            to: "to always",
            description: description,
            captureExceptions: false
        )
        return try verify(pass, msg, try expression.evaluate())
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    ///
    /// @warning
    /// This form of `alwaysTo` does not work in any kind of async context.
    /// Use the async form of `alwaysTo` if you are running tests in an async context.
    @available(*, noasync, message: "the sync variant of `alwaysTo` does not work in async contexts. Use the async variant as a drop-in replacement")
    @discardableResult
    public func alwaysTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) throws -> Value {
        return try toAlways(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    // MARK: - Async Polling with Synchronous Matchers
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventually(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
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
                        try matcher.satisfies(expression.withoutCaching())
                    }
            }
        return try verify(pass, msg, try await asyncExpression.evaluate())
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventuallyNot(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
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
                        try matcher.satisfies(expression.withoutCaching())
                    }
            }
        return try verify(pass, msg, try await asyncExpression.evaluate())
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    @discardableResult
    public func toNotEventually(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toNever(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)
        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toNotMatch,
            to: "to never",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toNotMatch,
                    matchStyle: .never,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toNever") { @MainActor in
                        try matcher.satisfies(expression.withoutCaching())
                    }
            }
        return try verify(pass, msg, try await asyncExpression.evaluate())
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    @discardableResult
    public func neverTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toNever(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    @discardableResult
    public func toAlways(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)
        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toMatch,
            to: "to always",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toMatch,
                    matchStyle: .always,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toAlways") { @MainActor in
                        try matcher.satisfies(expression.withoutCaching())
                    }
            }
        return try verify(pass, msg, try await asyncExpression.evaluate())
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    @discardableResult
    public func alwaysTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toAlways(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    // MARK: - Async Polling With AsyncMatchers
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventually(_ matcher: AsyncMatcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
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
                        try await matcher.satisfies(expression.withoutCaching().toAsyncExpression())
                    }
            }
        return try verify(pass, msg, try await asyncExpression.evaluate())
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventuallyNot(_ matcher: AsyncMatcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
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
                        try await matcher.satisfies(expression.withoutCaching().toAsyncExpression())
                    }
            }
        return try verify(pass, msg, try await asyncExpression.evaluate())
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    @discardableResult
    public func toNotEventually(_ matcher: AsyncMatcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toNever(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)
        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toNotMatch,
            to: "to never",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toNotMatch,
                    matchStyle: .never,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toNever") { @MainActor in
                        try await matcher.satisfies(expression.withoutCaching().toAsyncExpression())
                    }
            }
        return try verify(pass, msg, try await asyncExpression.evaluate())
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    @discardableResult
    public func neverTo(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toNever(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    @discardableResult
    public func toAlways(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)
        let asyncExpression = expression.toAsyncExpression()

        let (pass, msg) = await execute(
            asyncExpression,
            style: .toMatch,
            to: "to always",
            description: description) {
                await poll(
                    expression: asyncExpression,
                    style: .toMatch,
                    matchStyle: .always,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toAlways") { @MainActor in
                        try await matcher.satisfies(expression.withoutCaching().toAsyncExpression())
                    }
            }
        return try verify(pass, msg, try await asyncExpression.evaluate())
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    @discardableResult
    public func alwaysTo(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toAlways(matcher, until: until, pollInterval: pollInterval, description: description)
    }
}

extension AsyncRequirement {
    // MARK: - Async Polling With Synchronous Matchers
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventually(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
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
                        try matcher.satisfies(await expression.withoutCaching().toSynchronousExpression())
                    }
            }
        return try verify(pass, msg, try await expression.evaluate())
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventuallyNot(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
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
                        try matcher.satisfies(await expression.withoutCaching().toSynchronousExpression())
                    }
            }
        return try verify(pass, msg, try await expression.evaluate())
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    @discardableResult
    public func toNotEventually(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toNever(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toNotMatch,
            to: "to never",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toNotMatch,
                    matchStyle: .never,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toNever") {
                        try matcher.satisfies(await expression.withoutCaching().toSynchronousExpression())
                    }
            }
        return try verify(pass, msg, try await expression.evaluate())
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    @discardableResult
    public func neverTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toNever(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    @discardableResult
    public func toAlways(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toMatch,
            to: "to always",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toMatch,
                    matchStyle: .always,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toAlways") {
                        try matcher.satisfies(await expression.withoutCaching().toSynchronousExpression())
                    }
            }
        return try verify(pass, msg, try await expression.evaluate())
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    @discardableResult
    public func alwaysTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toAlways(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    // MARK: - Async Polling With AsyncMatchers
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventually(_ matcher: AsyncMatcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
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
                        try await matcher.satisfies(expression.withoutCaching())
                    }
            }
        return try verify(pass, msg, try await expression.evaluate())
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toEventuallyNot(_ matcher: AsyncMatcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
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
                        try await matcher.satisfies(expression.withoutCaching())
                    }
            }
        return try verify(pass, msg, try await expression.evaluate())
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    @discardableResult
    public func toNotEventually(_ matcher: AsyncMatcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    @discardableResult
    public func toNever(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toNotMatch,
            to: "to never",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toNotMatch,
                    matchStyle: .never,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toNever") {
                        try await matcher.satisfies(expression.withoutCaching())
                    }
            }
        return try verify(pass, msg, try await expression.evaluate())
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    @discardableResult
    public func neverTo(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toNever(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    @discardableResult
    public func toAlways(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = await execute(
            expression,
            style: .toMatch,
            to: "to always",
            description: description) {
                await poll(
                    expression: expression,
                    style: .toMatch,
                    matchStyle: .always,
                    timeout: until,
                    poll: pollInterval,
                    fnName: "toAlways") {
                        try await matcher.satisfies(expression.withoutCaching())
                    }
            }
        return try verify(pass, msg, try await expression.evaluate())
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    @discardableResult
    public func alwaysTo(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toAlways(matcher, until: until, pollInterval: pollInterval, description: description)
    }
}

// MARK: - UnwrapEventually

/// Makes sure that the expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `require(expression).toEventuallyNot(beNil())`
@discardableResult
public func pollUnwrap<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure @escaping () throws -> T?) throws -> T {
    try require(file: file, line: line, expression()).toEventuallyNot(beNil())
}

/// Makes sure that the expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `require(expression).toEventuallyNot(beNil())`
@discardableResult
public func pollUnwrap<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure () -> (() throws -> T?)) throws -> T {
    try require(file: file, line: line, expression()).toEventuallyNot(beNil())
}

/// Makes sure that the expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `require(expression).toEventuallyNot(beNil())`
@discardableResult
public func pollUnwraps<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure @escaping () throws -> T?) throws -> T {
    try require(file: file, line: line, expression()).toEventuallyNot(beNil())
}

/// Makes sure that the expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `require(expression).toEventuallyNot(beNil())`
@discardableResult
public func pollUnwraps<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure () -> (() throws -> T?)) throws -> T {
    try require(file: file, line: line, expression()).toEventuallyNot(beNil())
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requirea(expression).toEventuallyNot(beNil())`
@discardableResult
public func pollUnwrap<T>(file: FileString = #file, line: UInt = #line, _ expression: @escaping () async throws -> T?) async throws -> T {
    try await requirea(file: file, line: line, try await expression()).toEventuallyNot(beNil())
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requirea(expression).toEventuallyNot(beNil())`
@discardableResult
public func pollUnwrap<T>(file: FileString = #file, line: UInt = #line, _ expression: () -> (() async throws -> T?)) async throws -> T {
    try await requirea(file: file, line: line, expression()).toEventuallyNot(beNil())
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requirea(expression).toEventuallyNot(beNil())`
@discardableResult
public func pollUnwrapa<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure @escaping () async throws -> T?) async throws -> T {
    try await requirea(file: file, line: line, try await expression()).toEventuallyNot(beNil())
}

/// Makes sure that the async expression evaluates to a non-nil value, otherwise throw an error.
/// As you can tell, this is a much less verbose equivalent to `requirea(expression).toEventuallyNot(beNil())`
@discardableResult
public func pollUnwrapa<T>(file: FileString = #file, line: UInt = #line, _ expression: @autoclosure () -> (() async throws -> T?)) async throws -> T {
    try await requirea(file: file, line: line, expression()).toEventuallyNot(beNil())
}

#endif // #if !os(WASI)
