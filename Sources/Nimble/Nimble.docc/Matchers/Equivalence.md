#  Equivalence

```swift
// Swift

// Passes if 'actual' is equivalent to 'expected':
expect(actual).to(equal(expected))
expect(actual) == expected

// Passes if 'actual' is not equivalent to 'expected':
expect(actual).toNot(equal(expected))
expect(actual) != expected
```

```objc
// Objective-C

// Passes if 'actual' is equivalent to 'expected':
expect(actual).to(equal(expected))

// Passes if 'actual' is not equivalent to 'expected':
expect(actual).toNot(equal(expected))
```

Values must be `Equatable`, `Comparable`, or subclasses of `NSObject`.
`equal` will always fail when used to compare one or more `nil` values.
