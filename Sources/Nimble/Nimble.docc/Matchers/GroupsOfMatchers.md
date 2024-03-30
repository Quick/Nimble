# Matching a value to any of a group of matchers

```swift
// Swift

// passes if actual is either less than 10 or greater than 20
expect(actual).to(satisfyAnyOf(beLessThan(10), beGreaterThan(20)))

// can include any number of matchers -- the following will pass
// **be careful** -- too many matchers can be the sign of an unfocused test
expect(6).to(satisfyAnyOf(equal(2), equal(3), equal(4), equal(5), equal(6), equal(7)))

// in Swift you also have the option to use the || operator to achieve a similar function
expect(82).to(beLessThan(50) || beGreaterThan(80))
```

> Note: In swift, you can mix and match synchronous and asynchronous matchers using by `satisfyAnyOf`/`||`.

```objc
// Objective-C

// passes if actual is either less than 10 or greater than 20
expect(actual).to(satisfyAnyOf(beLessThan(@10), beGreaterThan(@20)))

// can include any number of matchers -- the following will pass
// **be careful** -- too many matchers can be the sign of an unfocused test
expect(@6).to(satisfyAnyOf(equal(@2), equal(@3), equal(@4), equal(@5), equal(@6), equal(@7)))
```

Note: This matcher allows you to chain any number of matchers together. This provides flexibility,
      but if you find yourself chaining many matchers together in one test, consider whether you
      could instead refactor that single test into multiple, more precisely focused tests for
      better coverage.
