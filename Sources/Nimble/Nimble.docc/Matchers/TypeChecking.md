#  Type Checking

Nimble supports checking the type membership of any kind of object, whether
Objective-C conformant or not.

```swift
// Swift

protocol SomeProtocol{}
class SomeClassConformingToProtocol: SomeProtocol{}
struct SomeStructConformingToProtocol: SomeProtocol{}

// The following tests pass
expect(1).to(beAKindOf(Int.self))
expect("turtle").to(beAKindOf(String.self))

let classObject = SomeClassConformingToProtocol()
expect(classObject).to(beAKindOf(SomeProtocol.self))
expect(classObject).to(beAKindOf(SomeClassConformingToProtocol.self))
expect(classObject).toNot(beAKindOf(SomeStructConformingToProtocol.self))

let structObject = SomeStructConformingToProtocol()
expect(structObject).to(beAKindOf(SomeProtocol.self))
expect(structObject).to(beAKindOf(SomeStructConformingToProtocol.self))
expect(structObject).toNot(beAKindOf(SomeClassConformingToProtocol.self))
```

```objc
// Objective-C

// The following tests pass
NSMutableArray *array = [NSMutableArray array];
expect(array).to(beAKindOf([NSArray class]));
expect(@1).toNot(beAKindOf([NSNull class]));
```

Objects can be tested for their exact types using the `beAnInstanceOf` matcher:

```swift
// Swift

protocol SomeProtocol{}
class SomeClassConformingToProtocol: SomeProtocol{}
struct SomeStructConformingToProtocol: SomeProtocol{}

// Unlike the 'beKindOf' matcher, the 'beAnInstanceOf' matcher only
// passes if the object is the EXACT type requested. The following
// tests pass -- note its behavior when working in an inheritance hierarchy.
expect(1).to(beAnInstanceOf(Int.self))
expect("turtle").to(beAnInstanceOf(String.self))

let classObject = SomeClassConformingToProtocol()
expect(classObject).toNot(beAnInstanceOf(SomeProtocol.self))
expect(classObject).to(beAnInstanceOf(SomeClassConformingToProtocol.self))
expect(classObject).toNot(beAnInstanceOf(SomeStructConformingToProtocol.self))

let structObject = SomeStructConformingToProtocol()
expect(structObject).toNot(beAnInstanceOf(SomeProtocol.self))
expect(structObject).to(beAnInstanceOf(SomeStructConformingToProtocol.self))
expect(structObject).toNot(beAnInstanceOf(SomeClassConformingToProtocol.self))
```
