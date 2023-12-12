// swiftlint:disable file_length
#if !os(WASI)

import Dispatch

extension SyncRequirement {
    // MARK: - With Synchronous Matchers
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
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
    public func toNotEventually(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
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
                    style: .toMatch,
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
    public func neverTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toNever(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
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
                    style: .toNotMatch,
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
    public func alwaysTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toAlways(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    // MARK: - With AsyncMatchers
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
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
    public func toNotEventually(_ matcher: AsyncMatcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
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
                    style: .toMatch,
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
    public func neverTo(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toNever(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
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
                    style: .toNotMatch,
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
    public func alwaysTo(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toAlways(matcher, until: until, pollInterval: pollInterval, description: description)
    }
}

extension AsyncRequirement {
    // MARK: - With Synchronous Matchers
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
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
    public func toNotEventually(_ matcher: Matcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    public func toNever(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
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
                        try matcher.satisfies(await expression.withoutCaching().toSynchronousExpression())
                    }
            }
        return try verify(pass, msg, try await expression.evaluate())
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    public func neverTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toNever(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    public func toAlways(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
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
                        try matcher.satisfies(await expression.withoutCaching().toSynchronousExpression())
                    }
            }
        return try verify(pass, msg, try await expression.evaluate())
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    public func alwaysTo(_ matcher: Matcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toAlways(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    // MARK: - With AsyncMatchers
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
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
    public func toNotEventually(_ matcher: AsyncMatcher<Value>, timeout: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    public func toNever(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
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
                        try await matcher.satisfies(expression.withoutCaching())
                    }
            }
        return try verify(pass, msg, try await expression.evaluate())
    }

    /// Tests the actual value using a matcher to never match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toNever()
    public func neverTo(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toNever(matcher, until: until, pollInterval: pollInterval, description: description)
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    public func toAlways(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
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
                        try await matcher.satisfies(expression.withoutCaching())
                    }
            }
        return try verify(pass, msg, try await expression.evaluate())
    }

    /// Tests the actual value using a matcher to always match by checking
    /// continusouly at each pollInterval until the timeout is reached
    ///
    /// Alias of toAlways()
    public func alwaysTo(_ matcher: AsyncMatcher<Value>, until: NimbleTimeInterval = PollingDefaults.timeout, pollInterval: NimbleTimeInterval = PollingDefaults.pollInterval, description: String? = nil) async throws -> Value {
        return try await toAlways(matcher, until: until, pollInterval: pollInterval, description: description)
    }
}

#endif // #if !os(WASI)
