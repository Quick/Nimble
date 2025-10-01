# Some Background: Expressing Outcomes Using Assertions in XCTest

Apple's Xcode includes the XCTest framework, which provides
assertion macros to test whether code behaves properly.
For example, to assert that `1 + 1 = 2`, XCTest has you write:

```swift
// Swift

XCTAssertEqual(1 + 1, 2, "expected one plus one to equal two")
```

Or, in Objective-C:

```objc
// Objective-C

XCTAssertEqual(1 + 1, 2, @"expected one plus one to equal two");
```

XCTest assertions have a couple of drawbacks:

1. **Not enough macros.** There's no easy way to assert that a string
   contains a particular substring, or that a number is less than or
   equal to another.
2. **It's hard to check expressions that change over time.** XCTest forces you to write
   a lot of boilerplate code.

Nimble addresses these concerns.
