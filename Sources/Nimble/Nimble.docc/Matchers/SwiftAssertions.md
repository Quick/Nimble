# Swift Assertions

If you're using Swift, you can use the `throwAssertion` matcher to check if an assertion is thrown (e.g. `fatalError()`). This is made possible by [@mattgallagher](https://github.com/mattgallagher)'s [CwlPreconditionTesting](https://github.com/mattgallagher/CwlPreconditionTesting) library.

```swift
// Swift

// Passes if 'somethingThatThrows()' throws an assertion, 
// such as by calling 'fatalError()' or if a precondition fails:
expect { try somethingThatThrows() }.to(throwAssertion())
expect { () -> Void in fatalError() }.to(throwAssertion())
expect { precondition(false) }.to(throwAssertion())

// Passes if throwing an NSError is not equal to throwing an assertion:
expect { throw NSError(domain: "test", code: 0, userInfo: nil) }.toNot(throwAssertion())

// Passes if the code after the precondition check is not run:
var reachedPoint1 = false
var reachedPoint2 = false
expect {
    reachedPoint1 = true
    precondition(false, "condition message")
    reachedPoint2 = true
}.to(throwAssertion())

expect(reachedPoint1) == true
expect(reachedPoint2) == false
```

Notes:

* This feature is only available in Swift.
* The tvOS simulator is supported, but using a different mechanism, requiring you to turn off the `Debug executable` scheme setting for your tvOS scheme's Test configuration.
