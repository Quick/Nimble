# Mapping a Value to Another Value

Sometimes, you only want to match against a property or group of properties.
For example, if you wanted to check that only one or a few properties of a value
are equal to something else. For this, use the ``map`` matcher to convert a value
to another value and check it with a matcher.

```swift
// Swift

expect(someValue).to(map(\.someProperty, equal(expectedProperty)))

// or, for checking multiple different properties:

expect(someValue).to(satisfyAllOf(
    map(\.firstProperty, equal(expectedFirstProperty)),
    map({ $0.secondProperty }, equal(expectedSecondProperty))
))
```

The ``map`` matcher takes in either a closure or a keypath literal, and a matcher
to compose with. It also works with async closures and async matchers.

In most cases, it is simpler and easier to not use map (that is, prefer
`expect(someValue.property).to(equal(1))` to
`expect(someValue).to(map(\.property, equal(1)))`). But `map` is incredibly
useful when combined with `satisfyAllOf`/`satisfyAnyOf`, especially for checking
a value that cannot conform to `Equatable` (or you don't want to make it
conform to `Equatable`). However, if you find yourself reusing `map` many times
to do a fuzzy-equals of a given type, you will find writing a custom matcher to
be much easier to use and maintain.

> Warning: When using Polling Expectations be careful not run process intensive
code since the map closure will be ran many times.
