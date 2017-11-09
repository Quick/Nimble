import Foundation

/// A proxt type to allow protocol extension-based matchers
///
/// Use `ExtensibleExpectation` proxy as follows:
///
/// // 1. Extend ExtensibleExpectation with constrain on Type
/// // Read as: ExtensibleExpectation Extension where Type is a SomeType
/// extension ExtensibleExpectation where Type: SomeType {
/// // 2. Define any type specific matchers
///     func equal(_ expectedValue: Type) {
///         match {actualExpression -> Predicate<Type> in
///             // Build a predicate
///         }
///     }
/// }
///
/// With this approach we can have more readable matcher syntax like `expect(1).to.equal(1)` instead of `expect(1).to(equal(1))`
public struct ExtensibleExpecation<Type> {
    public typealias T = Type
    private let base: Expectation<T>
    private let style: ExpectationStyle
    
    private let isAsync: Bool
    init(base: Expectation<T>, style: ExpectationStyle,
         isAsync: Bool = false
        ) {
        self.base = base
        self.style = style
        
        self.isAsync = isAsync
    }
    
    public func match(description: String? = nil, _ predicateFactory: @escaping () -> Predicate<T>) {
        if isAsync {
            nimblePrecondition(base.expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)
        }
        
        let to = style == .toMatch ? "to" : "to not"
        let predicate = isAsync ?
            predicateFactory() :
            async(style: style,
                  predicate: predicateFactory(),
                  timeout: AsyncDefaults.Timeout,
                  poll: AsyncDefaults.PollInterval,
                  fnName: style == .toMatch ? "toEventually" : "toEventuallyNot")
        
        let (pass, msg) = execute(base.expression,
                                  style,
                                  predicate,
                                  to: to,
                                  description: description)
        base.verify(pass, msg)
    }
}

//MARK: Expectation extensions
extension Expectation {
    /// Expectation extension to test the actual value using a matcher to match.
    public var to: ExtensibleExpecation<T> {
        return ExtensibleExpecation(base: self, style: .toMatch)
    }
    
    /// Expectation extension to test the actual value using a matcher to not match
    public var notTo: ExtensibleExpecation<T> {
        return ExtensibleExpecation(base: self, style: .toNotMatch)
    }
    
    /// Expectation extension to test the actual value using a matcher to not match
    ///
    /// Alias to `notTo`.
    public var toNot: ExtensibleExpecation<T> {
        return notTo
    }
}

//MARK: Async Expectation Extensions
extension Expectation {
    
    /// Expectation extension to test the actual value using a matcher to match by checking continously at default poll interval until the default timeout is reached.
    public var toEventually: ExtensibleExpecation<T> {
        return ExtensibleExpecation(base: self,
                                    style: .toMatch,
                                    isAsync: true)
    }
    
    /// Expectation extension to test the actual value using a matcher to not match by checking continously at default poll interval until the default timeout is reached.
    public var toEventuallyNot: ExtensibleExpecation<T> {
        return ExtensibleExpecation(base: self,
                                    style: .toNotMatch,
                                    isAsync: true)
    }
    
    /// Expectation extension to test the actual value using a matcher to not match by checking continously at default poll interval until the default timeout is reached.
    ///
    /// Alias to `toEventuallyNot`
    public var toNotEventually: ExtensibleExpecation<T> {
        return toEventuallyNot
    }
}
