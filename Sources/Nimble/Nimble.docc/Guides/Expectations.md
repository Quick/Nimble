# Expectations Using `expect(...).to`

Nimble allows you to express expectations using a natural,
easily understood language:

```swift
// Swift

import Nimble

expect(seagull.squawk).to(equal("Squee!"))
```

```objc
// Objective-C

@import Nimble;

expect(seagull.squawk).to(equal(@"Squee!"));
```

> The `expect` function autocompletes to include `file:` and `line:`,
  but these parameters are optional. Use the default values to have
  Xcode highlight the correct line when an expectation is not met.

To perform the opposite expectation--to assert something is *not*
equal--use `toNot` or `notTo`:

```swift
// Swift

import Nimble

expect(seagull.squawk).toNot(equal("Oh, hello there!"))
expect(seagull.squawk).notTo(equal("Oh, hello there!"))
```

```objc
// Objective-C

@import Nimble;

expect(seagull.squawk).toNot(equal(@"Oh, hello there!"));
expect(seagull.squawk).notTo(equal(@"Oh, hello there!"));
```

## Custom Failure Messages

Would you like to add more information to the test's failure messages? Use the `description` optional argument to add your own text:

```swift
// Swift

expect(1 + 1).to(equal(3))
// failed - expected to equal <3>, got <2>

expect(1 + 1).to(equal(3), description: "Make sure libKindergartenMath is loaded")
// failed - Make sure libKindergartenMath is loaded
// expected to equal <3>, got <2>
```

Or the *WithDescription version in Objective-C:

```objc
// Objective-C

@import Nimble;

expect(@(1+1)).to(equal(@3));
// failed - expected to equal <3.0000>, got <2.0000>

expect(@(1+1)).toWithDescription(equal(@3), @"Make sure libKindergartenMath is loaded");
// failed - Make sure libKindergartenMath is loaded
// expected to equal <3.0000>, got <2.0000>
```

## Type Safety

Nimble makes sure you don't compare two types that don't match:

```swift
// Swift

// Does not compile:
expect(1 + 1).to(equal("Squee!"))
```

> Nimble uses generics--only available in Swift--to ensure
  type correctness. That means type checking is
  not available when using Nimble in Objective-C. :sob:

## Operator Overloads

Tired of so much typing? With Nimble, you can use overloaded operators
like `==` for equivalence, or `>` for comparisons:

```swift
// Swift

// Passes if squawk does not equal "Hi!":
expect(seagull.squawk) != "Hi!"

// Passes if 10 is greater than 2:
expect(10) > 2
```

> Operator overloads are only available in Swift, so you won't be able
  to use this syntax in Objective-C. :broken_heart:

## Lazily Computed Values

The `expect` function doesn't evaluate the value it's given until it's
time to match. So Nimble can test whether an expression raises an
exception once evaluated:

```swift
// Swift

// Note: Swift currently doesn't have exceptions.
//       Only Objective-C code can raise exceptions
//       that Nimble will catch.
//       (see https://github.com/Quick/Nimble/issues/220#issuecomment-172667064)
let exception = NSException(
    name: NSInternalInconsistencyException,
    reason: "Not enough fish in the sea.",
    userInfo: ["something": "is fishy"])
expect { exception.raise() }.to(raiseException())

// Also, you can customize raiseException to be more specific
expect { exception.raise() }.to(raiseException(named: NSInternalInconsistencyException))
expect { exception.raise() }.to(raiseException(
    named: NSInternalInconsistencyException,
    reason: "Not enough fish in the sea"))
expect { exception.raise() }.to(raiseException(
    named: NSInternalInconsistencyException,
    reason: "Not enough fish in the sea",
    userInfo: ["something": "is fishy"]))
```

Objective-C works the same way, but you must use the `expectAction`
macro when making an expectation on an expression that has no return
value:

```objc
// Objective-C

NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                 reason:@"Not enough fish in the sea."
                                               userInfo:nil];
expectAction(^{ [exception raise]; }).to(raiseException());

// Use the property-block syntax to be more specific.
expectAction(^{ [exception raise]; }).to(raiseException().named(NSInternalInconsistencyException));
expectAction(^{ [exception raise]; }).to(raiseException().
    named(NSInternalInconsistencyException).
    reason("Not enough fish in the sea"));
expectAction(^{ [exception raise]; }).to(raiseException().
    named(NSInternalInconsistencyException).
    reason("Not enough fish in the sea").
    userInfo(@{@"something": @"is fishy"}));

// You can also pass a block for custom matching of the raised exception
expectAction(exception.raise()).to(raiseException().satisfyingBlock(^(NSException *exception) {
    expect(exception.name).to(beginWith(NSInternalInconsistencyException));
}));
```

## C Primitives

Some testing frameworks make it hard to test primitive C values.
In Nimble, it just works:

```swift
// Swift

let actual: CInt = 1
let expectedValue: CInt = 1
expect(actual).to(equal(expectedValue))
```

In fact, Nimble uses type inference, so you can write the above
without explicitly specifying both types:

```swift
// Swift

expect(1 as CInt).to(equal(1))
```

> In Objective-C, Nimble only supports Objective-C objects. To
  make expectations on primitive C values, wrap then in an object
  literal:

```objc
expect(@(1 + 1)).to(equal(@2));
```
