# Truthiness

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
