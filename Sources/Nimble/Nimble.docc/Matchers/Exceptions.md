# Exceptions

```swift
// Swift

// Passes if 'actual', when evaluated, raises an exception:
expect(actual).to(raiseException())

// Passes if 'actual' raises an exception with the given name:
expect(actual).to(raiseException(named: name))

// Passes if 'actual' raises an exception with the given name and reason:
expect(actual).to(raiseException(named: name, reason: reason))

// Passes if 'actual' raises an exception which passes expectations defined in the given closure:
// (in this case, if the exception's name begins with "a r")
expect { exception.raise() }.to(raiseException { (exception: NSException) in
    expect(exception.name).to(beginWith("a r"))
})
```

```objc
// Objective-C

// Passes if 'actual', when evaluated, raises an exception:
expect(actual).to(raiseException())

// Passes if 'actual' raises an exception with the given name
expect(actual).to(raiseException().named(name))

// Passes if 'actual' raises an exception with the given name and reason:
expect(actual).to(raiseException().named(name).reason(reason))

// Passes if 'actual' raises an exception and it passes expectations defined in the given block:
// (in this case, if name begins with "a r")
expect(actual).to(raiseException().satisfyingBlock(^(NSException *exception) {
    expect(exception.name).to(beginWith(@"a r"));
}));
```

> Note: Swift currently doesn't have exceptions (see [#220](https://github.com/Quick/Nimble/issues/220#issuecomment-172667064)). 
Only Objective-C code can raise exceptions that Nimble will catch.

> Note: ``raiseException()`` is currentl unavailable when Nimble is installed
through Swift Package Manager.
