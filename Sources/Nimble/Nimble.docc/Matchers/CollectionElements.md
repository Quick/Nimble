# Collection Elements

Nimble provides a means to check that all elements of a collection pass a given expectation.

## Swift

In Swift, the collection must be an instance of a type conforming to
`Sequence`.

```swift
// Swift

// Providing a custom function:
expect([1, 2, 3, 4]).to(allPass { $0 < 5 })

// Composing the expectation with another matcher:
expect([1, 2, 3, 4]).to(allPass(beLessThan(5)))
```

There are also variants of `allPass` that check against async matchers, and
that take in async functions:

```swift
// Swift

// Providing a custom function:
expect([1, 2, 3, 4]).to(allPass { await asyncFunctionReturningBool($0) })

// Composing the expectation with another matcher:
expect([1, 2, 3, 4]).to(allPass(someAsyncMatcher()))
```

## Objective-C

In Objective-C, the collection must be an instance of a type which implements
the `NSFastEnumeration` protocol, and whose elements are instances of a type
which subclasses `NSObject`.

Additionally, unlike in Swift, there is no override to specify a custom
matcher function.

```objc
// Objective-C

expect(@[@1, @2, @3, @4]).to(allPass(beLessThan(@5)));
```

