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
    
    public enum Status: Equatable {
        
        /// No predicates have been performed.
        case pending
        
        /// All predicates have passed.
        case passed
        
        /// All predicates have failed.
        case failed
        
        /// Multiple predicates have been peformed, with at least one passing and one failing.
        case mixed
    }

    public let expression: Expression<T>
    
    /// The status of the test after predicates have been evaluated.
    ///
    /// This property can be used for changing test behavior based whether an expectation has
    /// passed.
    ///
    /// In the below example, we perform additional tests on an array only if it has enough
    /// elements.
    ///
    /// ```
    /// if expect(array).to(haveCount(10)).status == .passed {
    ///    expect(array[9]).to(...)
    /// }
    /// ```
    public let status: Status

    private init(expression: Expression<T>, status: Status) {
        self.expression = expression
        self.status = status
    }

    public init(expression: Expression<T>) {
        self.init(expression: expression, status: .pending)
    }
    
    /// Takes the result of a test and passes it to the assertion handler.
    ///
    /// - Returns: An updated `Expression` with the result of the test applied to the `status`
    ///            property.
    @discardableResult
    public func verify(_ pass: Bool, _ message: FailureMessage) -> Self {
        let handler = NimbleEnvironment.activeInstance.assertionHandler
        handler.assert(pass, message: message, location: expression.location)
        
        return .init(expression: expression, status: status.applying(pass ? .passed : .failed))
    }

    /// Tests the actual value using a matcher to match.
    @discardableResult
    public func to(_ predicate: Predicate<T>, description: String? = nil) -> Self {
        let (pass, msg) = execute(expression, .toMatch, predicate, to: "to", description: description)
        return verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match.
    @discardableResult
    public func toNot(_ predicate: Predicate<T>, description: String? = nil) -> Self {
        let (pass, msg) = execute(expression, .toNotMatch, predicate, to: "to not", description: description)
        return verify(pass, msg)
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

extension Expectation.Status {
    
    /// Applies a new status to the current one to produce a combined status.
    ///
    /// This method is meant to advance the state from `.pending` to either `.passed` or`.failed`.
    /// When called multiple times with different values, the result will be `.mixed`.
    /// E.g., `status.applying(.passed).applying(.failed) == .mixed`.
    func applying(_ newerStatus: Expectation.Status) -> Expectation.Status {
        if newerStatus == .pending { return self }
        if self == .pending || self == newerStatus { return newerStatus }
        return .mixed
    }
}
