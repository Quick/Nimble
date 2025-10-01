# Truthiness

Checking whether an expression is true, false, or nil.

The ``beTrue()`` matcher matches only if the expression evaluates to `true`, while
the ``beTruthy()`` matcher will also match if the expression also evaluates to a
non-`nil` value, or an object with a boolean value of `true`.

Similarly, the ``beFalse()`` matcher matches only if the expression evaluates to
`false`, while the ``beFalsy()`` also accepts `nil`, or objects with a boolean
value of `false`.

Finally, the ``beNil())`` matcher matches only if the expression evaluates to
`nil`.


```swift
// Passes if 'actual' is not nil, true, or an object with a boolean value of true:
expect(actual).to(beTruthy())

// Passes if 'actual' is only true (not nil or an object conforming to Boolean true):
expect(actual).to(beTrue())

// Passes if 'actual' is nil, false, or an object with a boolean value of false:
expect(actual).to(beFalsy())

// Passes if 'actual' is only false (not nil or an object conforming to Boolean false):
expect(actual).to(beFalse())

// Passes if 'actual' is nil:
expect(actual).to(beNil())
```

```objc
// Objective-C

// Passes if 'actual' is not nil, true, or an object with a boolean value of true:
expect(actual).to(beTruthy());

// Passes if 'actual' is only true (not nil or an object conforming to Boolean true):
expect(actual).to(beTrue());

// Passes if 'actual' is nil, false, or an object with a boolean value of false:
expect(actual).to(beFalsy());

// Passes if 'actual' is only false (not nil or an object conforming to Boolean false):
expect(actual).to(beFalse());

// Passes if 'actual' is nil:
expect(actual).to(beNil());
```
