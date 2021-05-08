internal func execute<T>(_ expression: Expression<T>, _ style: ExpectationStyle, _ predicate: Predicate<T>, to: String, description: String?, captureExceptions: Bool = true) -> (Bool, FailureMessage) {
    func run() -> (Bool, FailureMessage) {
        let msg = FailureMessage()
        msg.userDescription = description
        msg.to = to
        do {
            let result = try predicate.satisfies(expression)
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

    var result: (Bool, FailureMessage) = (false, FailureMessage())
    if captureExceptions {
        let capture = NMBExceptionCapture(handler: ({ exception -> Void in
            let msg = FailureMessage()
            msg.stringValue = "unexpected exception raised: \(exception)"
            result = (false, msg)
        }), finally: nil)
        capture.tryBlock {
            result = run()
        }
    } else {
        result = run()
    }

    return result
}

public struct Expectation<T> {

    public let expression: Expression<T>

    public init(expression: Expression<T>) {
        self.expression = expression
    }

    public func verify(_ pass: Bool, _ message: FailureMessage) {
        let handler = NimbleEnvironment.activeInstance.assertionHandler
        handler.assert(pass, message: message, location: expression.location)
    }

    /// Tests the actual value using a matcher to match.
    @discardableResult
    public func to(_ predicate: Predicate<T>, description: String? = nil) -> Self {
        let (pass, msg) = execute(expression, .toMatch, predicate, to: "to", description: description)
        verify(pass, msg)
        return self
    }

    /// Tests the actual value using a matcher to not match.
    @discardableResult
    public func toNot(_ predicate: Predicate<T>, description: String? = nil) -> Self {
        let (pass, msg) = execute(expression, .toNotMatch, predicate, to: "to not", description: description)
        verify(pass, msg)
        return self
    }

    /// Tests the actual value using a matcher to not match.
    ///
    /// Alias to toNot().
    @discardableResult
    public func notTo(_ predicate: Predicate<T>, description: String? = nil) -> Self {
        return toNot(predicate, description: description)
    }

    // see:
    // - `async` for extension
    // - NMBExpectation for Objective-C interface
}
