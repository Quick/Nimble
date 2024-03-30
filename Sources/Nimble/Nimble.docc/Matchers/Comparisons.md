# Comparisons

```swift
// Swift

expect(actual).to(beLessThan(expected))
expect(actual) < expected

expect(actual).to(beLessThanOrEqualTo(expected))
expect(actual) <= expected

expect(actual).to(beGreaterThan(expected))
expect(actual) > expected

expect(actual).to(beGreaterThanOrEqualTo(expected))
expect(actual) >= expected
```

```objc
// Objective-C

expect(actual).to(beLessThan(expected));
expect(actual).to(beLessThanOrEqualTo(expected));
expect(actual).to(beGreaterThan(expected));
expect(actual).to(beGreaterThanOrEqualTo(expected));
```

> Values given to the comparison matchers above must implement
  `Comparable`.

Because of how computers represent floating point numbers, assertions
that two floating point numbers be equal will sometimes fail. To express
that two numbers should be close to one another within a certain margin
of error, use `beCloseTo`:

```swift
// Swift

expect(actual).to(beCloseTo(expected, within: delta))
```

```objc
// Objective-C

expect(actual).to(beCloseTo(expected).within(delta));
```

For example, to assert that `10.01` is close to `10`, you can write:

```swift
// Swift

expect(10.01).to(beCloseTo(10, within: 0.1))
```

```objc
// Objective-C

expect(@(10.01)).to(beCloseTo(@10).within(0.1));
```

There is also an operator shortcut available in Swift:

```swift
// Swift

expect(actual) ≈ expected
expect(actual) ≈ (expected, delta)

```
(Type <kbd>option</kbd>+<kbd>x</kbd> to get `≈` on a U.S. keyboard)

The former version uses the default delta of 0.0001. Here is yet another way to do this:

```swift
// Swift

expect(actual) ≈ expected ± delta
expect(actual) == expected ± delta

```
(Type <kbd>option</kbd>+<kbd>shift</kbd>+<kbd>=</kbd> to get `±` on a U.S. keyboard)

If you are comparing arrays of floating point numbers, you'll find the following useful:

```swift
// Swift

expect([0.0, 2.0]) ≈ [0.0001, 2.0001]
expect([0.0, 2.0]).to(beCloseTo([0.1, 2.1], within: 0.1))

```

> Values given to the `beCloseTo` matcher must conform to `FloatingPoint`.
