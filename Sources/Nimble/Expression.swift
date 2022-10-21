// Memoizes the given closure, only calling the passed
// closure once; even if repeat calls to the returned closure
private func memoizedClosure<T>(_ closure: @escaping () throws -> T) -> (Bool) throws -> T {
    var cache: T?
    return { withoutCaching in
        if withoutCaching || cache == nil {
            cache = try closure()
        }
        return cache!
    }
}

/// Expression represents the closure of the value inside expect(...).
/// Expressions are memoized by default. This makes them safe to call
/// evaluate() multiple times without causing a re-evaluation of the underlying
/// closure.
///
/// - Warning: Since the closure can be any code, Objective-C code may choose
///          to raise an exception. Currently, SyncExpression does not memoize
///          exception raising.
///
/// This provides a common consumable API for matchers to utilize to allow
/// Nimble to change internals to how the captured closure is managed.
public struct Expression<Value> {
    internal let _expression: (Bool) throws -> Value?
    internal let _withoutCaching: Bool
    public let location: SourceLocation
    public let isClosure: Bool

    /// Creates a new expression struct. Normally, expect(...) will manage this
    /// creation process. The expression is memoized.
    ///
    /// - Parameter expression: The closure that produces a given value.
    /// - Parameter location: The source location that this closure originates from.
    /// - Parameter isClosure: A bool indicating if the captured expression is a
    ///                  closure or internally produced closure. Some matchers
    ///                  may require closures. For example, toEventually()
    ///                  requires an explicit closure. This gives Nimble
    ///                  flexibility if @autoclosure behavior changes between
    ///                  Swift versions. Nimble internals always sets this true.
    public init(expression: @escaping () throws -> Value?, location: SourceLocation, isClosure: Bool = true) {
        self._expression = memoizedClosure(expression)
        self.location = location
        self._withoutCaching = false
        self.isClosure = isClosure
    }

    /// Creates a new expression struct. Normally, expect(...) will manage this
    /// creation process.
    ///
    /// - Parameter expression: The closure that produces a given value.
    /// - Parameter location: The source location that this closure originates from.
    /// - Parameter withoutCaching: Indicates if the struct should memoize the given
    ///                       closure's result. Subsequent evaluate() calls will
    ///                       not call the given closure if this is true.
    /// - Parameter isClosure: A bool indicating if the captured expression is a
    ///                  closure or internally produced closure. Some matchers
    ///                  may require closures. For example, toEventually()
    ///                  requires an explicit closure. This gives Nimble
    ///                  flexibility if @autoclosure behavior changes between
    ///                  Swift versions. Nimble internals always sets this true.
    public init(memoizedExpression: @escaping (Bool) throws -> Value?, location: SourceLocation, withoutCaching: Bool, isClosure: Bool = true) {
        self._expression = memoizedExpression
        self.location = location
        self._withoutCaching = withoutCaching
        self.isClosure = isClosure
    }

    /// Returns a new Expression from the given expression. Identical to a map()
    /// on this type. This should be used only to typecast the Expression's
    /// closure value.
    ///
    /// The returned expression will preserve location and isClosure.
    ///
    /// - Parameter block: The block that can cast the current Expression value to a
    ///              new type.
    public func cast<U>(_ block: @escaping (Value?) throws -> U?) -> Expression<U> {
        return Expression<U>(
            expression: ({ try block(self.evaluate()) }),
            location: self.location,
            isClosure: self.isClosure
        )
    }

    public func evaluate() throws -> Value? {
        return try self._expression(_withoutCaching)
    }

    public func withoutCaching() -> Expression<Value> {
        return Expression(
            memoizedExpression: self._expression,
            location: location,
            withoutCaching: true,
            isClosure: isClosure
        )
    }
}
