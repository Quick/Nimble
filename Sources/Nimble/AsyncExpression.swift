// Memoizes the given closure, only calling the passed
// closure once; even if repeat calls to the returned closure
public actor MemoizedClosure<T: Sendable> {
    var cache: T?
    private let closure: @Sendable (Bool) async throws -> T?

    init(_ closure: @escaping @Sendable () async throws -> T?) {
        self.closure = { _ in try await closure() }
    }

    init(prememoized: @escaping @Sendable (Bool) async throws -> T?) {
        self.closure = prememoized
    }

    public func evaluate(_ withoutCaching: Bool) async throws -> T? {
        if withoutCaching == false, let cache {
            return cache
        }
        let value = try await closure(withoutCaching)
        cache = value
        return value
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
public struct AsyncExpression<Value: Sendable>: Sendable {
    internal let _expression: MemoizedClosure<Value>
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
    public init(expression: @escaping @Sendable () async throws -> Value?, location: SourceLocation, isClosure: Bool = true) {
        self._expression = MemoizedClosure<Value>(expression)
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
    public init(memoizedExpression: MemoizedClosure<Value>, location: SourceLocation, withoutCaching: Bool, isClosure: Bool = true) {
        self._expression = memoizedExpression
        self.location = location
        self._withoutCaching = withoutCaching
        self.isClosure = isClosure
    }

    /// Creates a new synchronous expression, for use in Predicates.
    public func toSynchronousExpression() async -> Expression<Value> {
        let value: Result<Value?, Error>
        do {
            value = .success(try await _expression.evaluate(self._withoutCaching))
        } catch {
            value = .failure(error)
        }
        return Expression(
            memoizedExpression: { _ in try value.get() },
            location: location,
            withoutCaching: false,
            isClosure: isClosure
        )
    }

    /// Returns a new Expression from the given expression. Identical to a map()
    /// on this type. This should be used only to typecast the Expression's
    /// closure value.
    ///
    /// The returned expression will preserve location and isClosure.
    ///
    /// - Parameter block: The block that can cast the current Expression value to a
    ///              new type.
    public func cast<U>(_ block: @escaping (Value?) throws -> U?) -> AsyncExpression<U> {
        return AsyncExpression<U>(
            expression: ({ try await block(self.evaluate()) }),
            location: self.location,
            isClosure: self.isClosure
        )
    }

    public func evaluate() async throws -> Value? {
        return try await self._expression.evaluate(_withoutCaching)
    }

    public func withoutCaching() -> AsyncExpression<Value> {
        return AsyncExpression(
            memoizedExpression: self._expression,
            location: location,
            withoutCaching: true,
            isClosure: isClosure
        )
    }
}

