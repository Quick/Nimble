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
    init(_ base: Expectation<T>) {
        self.base = base
    }

    public func match(description: String? = nil, _ predicateFactory: @escaping () -> Predicate<T>) {
        let (pass, msg) = execute(base.expression,
                                  .toMatch,
                                  predicateFactory(),
                                  to: "to",
                                  description: description)
        base.verify(pass, msg)
    }
}

//MARK: Expectation extensions
extension Expectation {
    /// Expectation extension to test the actual value using a matcher to match.
    public var to: ExtensibleExpecation<T> {
        return ExtensibleExpecation(self)
    }
}
