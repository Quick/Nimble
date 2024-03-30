# Collection Count

```swift
// Swift

// Passes if 'actual' contains the 'expected' number of elements:
expect(actual).to(haveCount(expected))

// Passes if 'actual' does _not_ contain the 'expected' number of elements:
expect(actual).notTo(haveCount(expected))
```

```objc
// Objective-C

// Passes if 'actual' contains the 'expected' number of elements:
expect(actual).to(haveCount(expected))

// Passes if 'actual' does _not_ contain the 'expected' number of elements:
expect(actual).notTo(haveCount(expected))
```

For Swift, the actual value must be an instance of a type conforming to `Collection`.
For example, instances of `Array`, `Dictionary`, or `Set`.

For Objective-C, the actual value must be one of the following classes, or their subclasses:

 - `NSArray`,
 - `NSDictionary`,
 - `NSSet`, or
 - `NSHashTable`.
