#  Identity

```swift
// Swift

// Passes if 'actual' has the same pointer address as 'expected':
expect(actual).to(beIdenticalTo(expected))
expect(actual) === expected

// Passes if 'actual' does not have the same pointer address as 'expected':
expect(actual).toNot(beIdenticalTo(expected))
expect(actual) !== expected
```

It is important to remember that `beIdenticalTo` only makes sense when comparing
types with reference semantics, which have a notion of identity. In Swift, 
that means types that are defined as a `class`. 

This matcher will not work when comparing types with value semantics such as
those defined as a `struct` or `enum`. If you need to compare two value types,
consider what it means for instances of your type to be identical. This may mean
comparing individual properties or, if it makes sense to do so, conforming your type 
to `Equatable` and using Nimble's equivalence matchers instead.


```objc
// Objective-C

// Passes if 'actual' has the same pointer address as 'expected':
expect(actual).to(beIdenticalTo(expected));

// Passes if 'actual' does not have the same pointer address as 'expected':
expect(actual).toNot(beIdenticalTo(expected));
```
