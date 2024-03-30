# Types/Classes

```swift
// Swift

// Passes if 'instance' is an instance of 'aClass':
expect(instance).to(beAnInstanceOf(aClass))

// Passes if 'instance' is an instance of 'aClass' or any of its subclasses:
expect(instance).to(beAKindOf(aClass))
```

```objc
// Objective-C

// Passes if 'instance' is an instance of 'aClass':
expect(instance).to(beAnInstanceOf(aClass));

// Passes if 'instance' is an instance of 'aClass' or any of its subclasses:
expect(instance).to(beAKindOf(aClass));
```

> Instances must be Objective-C objects: subclasses of `NSObject`,
  or Swift objects bridged to Objective-C with the `@objc` prefix.

For example, to assert that `dolphin` is a kind of `Mammal`:

```swift
// Swift

expect(dolphin).to(beAKindOf(Mammal))
```

```objc
// Objective-C

expect(dolphin).to(beAKindOf([Mammal class]));
```

> Note: `beAnInstanceOf` uses the `-[NSObject isMemberOfClass:]` method to
  test membership. `beAKindOf` uses `-[NSObject isKindOfClass:]`.
