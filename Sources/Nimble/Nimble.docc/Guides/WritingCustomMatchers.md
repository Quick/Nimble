# Writing Your Own Matchers

In Nimble, matchers are Swift functions that take an expected
value and return a `Matcher` closure. Take `equal`, for example:

```swift
// Swift

public func equal<T: Equatable>(expectedValue: T?) -> Matcher<T> {
    // Can be shortened to:
    //   Matcher { actual in  ... }
    //
    // But shown with types here for clarity.
    return Matcher { (actualExpression: Expression<T>) throws -> MatcherResult in
        let msg = ExpectationMessage.expectedActualValueTo("equal <\(expectedValue)>")
        if let actualValue = try actualExpression.evaluate() {
            return MatcherResult(
                bool: actualValue == expectedValue!,
                message: msg
            )
        } else {
            return MatcherResult(
                status: .fail,
                message: msg.appendedBeNilHint()
            )
        }
    }
}
```

The return value of a `Matcher` closure is a `MatcherResult` that indicates
whether the actual value matches the expectation and what error message to
display on failure.

> The actual `equal` matcher function does not match when
  `expected` are nil; the example above has been edited for brevity.

Since matchers are just Swift functions, you can define them anywhere:
at the top of your test file, in a file shared by all of your tests, or
in an Xcode project you distribute to others.

> If you write a matcher you think everyone can use, consider adding it
  to Nimble's built-in set of matchers by sending a pull request! Or
  distribute it yourself via GitHub.

For examples of how to write your own matchers, just check out the
[`Matchers` directory](https://github.com/Quick/Nimble/tree/main/Sources/Nimble/Matchers)
to see how Nimble's built-in set of matchers are implemented. You can
also check out the tips below.

## MatcherResult

``MatcherResult`` is the return struct that ``Matcher`` returns to indicate
success and failure. A `MatcherResult` is made up of two values:
``MatcherStatus`` and ``ExpectationMessage``.

Instead of a boolean, `MatcherStatus` captures a trinary set of values:

```swift
// Swift

public enum MatcherStatus {
// The matcher "passes" with the given expression
// eg - expect(1).to(equal(1))
case matches

// The matcher "fails" with the given expression
// eg - expect(1).toNot(equal(1))
case doesNotMatch

// The matcher never "passes" with the given expression, even if negated
// eg - expect(nil as Int?).toNot(equal(1))
case fail

// ...
}
```

Meanwhile, `ExpectationMessage` provides messaging semantics for error reporting.

```swift
// Swift

public indirect enum ExpectationMessage {
// Emits standard error message:
// eg - "expected to <string>, got <actual>"
case expectedActualValueTo(/* message: */ String)

// Allows any free-form message
// eg - "<string>"
case fail(/* message: */ String)

// ...
}
```

Matchers should usually depend on either ``.expectedActualValueTo(_:)`` or
``.fail(_:)`` when reporting errors. Special cases can be used for the other enum
cases.

Finally, if your Matcher utilizes other Matchers, you can utilize
``.appended(details:)`` and ``.appended(message:)`` methods to annotate an existing
error with more details.

A common message to append is failing on nils. For that, ``.appendedBeNilHint()``
can be used.

## Lazy Evaluation

`actualExpression` is a lazy, memoized closure around the value provided to the
``expect`` function. The expression can either be a closure or a value directly
passed to ``expect(_:)``. In order to determine whether that value matches,
custom matchers should call `actualExpression.evaluate()`:

```swift
// Swift

public func beNil<T>() -> Matcher<T> {
    // Matcher.simpleNilable(..) automatically generates ExpectationMessage for
    // us based on the string we provide to it. Also, the 'Nilable' postfix indicates
    // that this Matcher supports matching against nil actualExpressions, instead of
    // always resulting in a MatcherStatus.fail result -- which is true for
    // Matcher.simple(..)
    return Matcher.simpleNilable("be nil") { actualExpression in
        let actualValue = try actualExpression.evaluate()
        return MatcherStatus(bool: actualValue == nil)
    }
}
```

In the above example, `actualExpression` is not `nil` -- it is a closure
that returns a value. The value it returns, which is accessed via the
`evaluate()` method, may be `nil`. If that value is `nil`, the `beNil`
matcher function returns `true`, indicating that the expectation passed.

## Type Checking via Swift Generics

Using Swift's generics, matchers can constrain the type of the actual value
passed to the `expect` function by modifying the return type.

For example, the following matcher, `haveDescription`, only accepts actual
values that implement the `CustomStringConvertible` protocol. It checks their `description`
against the one provided to the matcher function, and passes if they are the same:

```swift
// Swift

public func haveDescription(description: String) -> Matcher<CustomStringConvertible> {
    return Matcher.simple("have description") { actual in
        return MatcherStatus(bool: actual.evaluate().description == description)
    }
}
```

## Customizing Failure Messages

When using `Matcher.simple(..)` or `Matcher.simpleNilable(..)`, Nimble
outputs the following failure message when an expectation fails:

```swift
// where `message` is the first string argument and
// `actual` is the actual value received in `expect(..)`
"expected to \(message), got <\(actual)>"
```

You can customize this message by modifying the way you create a `Matcher`.

### Basic Customization

For slightly more complex error messaging, receive the created failure message
with `Matcher.define(..)`:

```swift
// Swift

public func equal<T: Equatable>(_ expectedValue: T?) -> Matcher<T> {
    return Matcher.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        let actualValue = try actualExpression.evaluate()
        let matches = actualValue == expectedValue && expectedValue != nil
        if expectedValue == nil || actualValue == nil {
            if expectedValue == nil && actualValue != nil {
                return MatcherResult(
                    status: .fail,
                    message: msg.appendedBeNilHint()
                )
            }
            return MatcherResult(status: .fail, message: msg)
        }
        return MatcherResult(bool: matches, message: msg)
    }
}
```

In the example above, `msg` is defined based on the string given to
`Matcher.define`. The code looks akin to:

```swift
// Swift

let msg = ExpectationMessage.expectedActualValueTo("equal <\(stringify(expectedValue))>")
```

### Full Customization

To fully customize the behavior of the Matcher, use the overload that expects
a `MatcherResult` to be returned.

Along with `MatcherResult`, there are other `ExpectationMessage` enum values you can use:

```swift
public indirect enum ExpectationMessage {
// Emits standard error message:
// eg - "expected to <message>, got <actual>"
case expectedActualValueTo(/* message: */ String)

// Allows any free-form message
// eg - "<message>"
case fail(/* message: */ String)

// Emits standard error message with a custom actual value instead of the default.
// eg - "expected to <message>, got <actual>"
case expectedCustomValueTo(/* message: */ String, /* actual: */ String)

// Emits standard error message without mentioning the actual value
// eg - "expected to <message>"
case expectedTo(/* message: */ String)

// ...
}
```

For matchers that compose other matchers, there are a handful of helper
functions to annotate messages.

`appended(message: String)` is used to append to the original failure message:

```swift
// produces "expected to be true, got <actual> (use beFalse() for inverse)"
// appended message do show up inline in Xcode.
.expectedActualValueTo("be true").appended(message: " (use beFalse() for inverse)")
```

For a more comprehensive message that spans multiple lines, use
`appended(details: String)` instead:

```swift
// produces "expected to be true, got <actual>\n\nuse beFalse() for inverse\nor use beNil()"
// details do not show inline in Xcode, but do show up in test logs.
.expectedActualValueTo("be true").appended(details: "use beFalse() for inverse\nor use beNil()")
```

## Asynchronous Matchers

To write matchers against async expressions, return an instance of
`AsyncMatcher`. The closure passed to `AsyncMatcher` is async, and the
expression you evaluate is also asynchronous and needs to be awaited on.

```swift
// Swift

actor CallRecorder<Arguments> {
    private(set) var calls: [Arguments] = []
    
    func record(call: Arguments) {
        calls.append(call)
    }
}

func beCalled<Argument: Equatable>(with arguments: Argument) -> AsyncMatcher<CallRecorder<Argument>> {
    AsyncMatcher { (expression: AsyncExpression<CallRecorder<Argument>>) in
        let message = ExpectationMessage.expectedActualValueTo("be called with \(arguments)")
        guard let calls = try await expression.evaluate()?.calls else {
            return MatcherResult(status: .fail, message: message.appendedBeNilHint())
        }
        
        return MatcherResult(bool: calls.contains(args), message: message.appended(details: "called with \(calls)"))
    }
}
```

In this example, we created an actor to act as an object to record calls to an
async function. Then, we created the `beCalled(with:)` matcher to check if the
actor has received a call with the given arguments.

## Supporting Objective-C

To use a custom matcher written in Swift from Objective-C, you'll have
to extend the `NMBMatcher` class, adding a new class method for your
custom matcher. The example below defines the class method
`+[NMBMatcher beNilMatcher]`:

```swift
// Swift

extension NMBMatcher {
    @objc public class func beNilMatcher() -> NMBMatcher {
        return NMBMatcher { actualExpression in
            return try beNil().satisfies(actualExpression).toObjectiveC()
        }
    }
}
```

The above allows you to use the matcher from Objective-C:

```objc
// Objective-C

expect(actual).to([NMBMatcher beNilMatcher]());
```

To make the syntax easier to use, define a C function that calls the
class method:

```objc
// Objective-C

FOUNDATION_EXPORT NMBMatcher *beNil() {
    return [NMBMatcher beNilMatcher];
}
```

### Properly Handling `nil` in Objective-C Matchers

When supporting Objective-C, make sure you handle `nil` appropriately.
Like [Cedar](https://github.com/pivotal/cedar/issues/100),
**most matchers do not match with nil**. This is to bring prevent test
writers from being surprised by `nil` values where they did not expect
them.

Nimble provides the `beNil` matcher function for test writer that want
to make expectations on `nil` objects:

```objc
// Objective-C

expect(nil).to(equal(nil)); // fails
expect(nil).to(beNil());    // passes
```

If your matcher does not want to match with nil, you use `Matcher.define` or `Matcher.simple`. 
Using those factory methods will automatically generate expected value failure messages when they're nil.

```swift
public func beginWith<S: Sequence>(_ startingElement: S.Element) -> Matcher<S> where S.Element: Equatable {
    return Matcher.simple("begin with <\(startingElement)>") { actualExpression in
        guard let actualValue = try actualExpression.evaluate() else { return .fail }

        var actualGenerator = actualValue.makeIterator()
        return MatcherStatus(bool: actualGenerator.next() == startingElement)
    }
}

extension NMBMatcher {
    @objc public class func beginWithMatcher(_ expected: Any) -> NMBMatcher {
        return NMBMatcher { actualExpression in
            let actual = try actualExpression.evaluate()
            let expr = actualExpression.cast { $0 as? NMBOrderedCollection }
            return try beginWith(expected).satisfies(expr).toObjectiveC()
        }
    }
}
```
