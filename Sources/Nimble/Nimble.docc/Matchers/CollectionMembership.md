# Collection Membership

```swift
// Swift

// Passes if all of the expected values are members of 'actual':
expect(actual).to(contain(expected...))

// Passes if 'actual' is empty (i.e. it contains no elements):
expect(actual).to(beEmpty())
```

```objc
// Objective-C

// Passes if expected is a member of 'actual':
expect(actual).to(contain(expected));

// Passes if 'actual' is empty (i.e. it contains no elements):
expect(actual).to(beEmpty());
```

> In Swift `contain` takes any number of arguments. The expectation
  passes if all of them are members of the collection. In Objective-C,
  `contain` only takes one argument [for now](https://github.com/Quick/Nimble/issues/27).

For example, to assert that a list of sea creature names contains
"dolphin" and "starfish":

```swift
// Swift

expect(["whale", "dolphin", "starfish"]).to(contain("dolphin", "starfish"))
```

```objc
// Objective-C

expect(@[@"whale", @"dolphin", @"starfish"]).to(contain(@"dolphin"));
expect(@[@"whale", @"dolphin", @"starfish"]).to(contain(@"starfish"));
```

> `contain` and `beEmpty` expect collections to be instances of
  `NSArray`, `NSSet`, or a Swift collection composed of `Equatable` elements.

To test whether a set of elements is present at the beginning or end of
an ordered collection, use `beginWith` and `endWith`:

```swift
// Swift

// Passes if the elements in expected appear at the beginning of 'actual':
expect(actual).to(beginWith(expected...))

// Passes if the the elements in expected come at the end of 'actual':
expect(actual).to(endWith(expected...))
```

```objc
// Objective-C

// Passes if the elements in expected appear at the beginning of 'actual':
expect(actual).to(beginWith(expected));

// Passes if the the elements in expected come at the end of 'actual':
expect(actual).to(endWith(expected));
```

> `beginWith` and `endWith` expect collections to be instances of
  `NSArray`, or ordered Swift collections composed of `Equatable`
  elements.

  Like `contain`, in Objective-C `beginWith` and `endWith` only support
  a single argument [for now](https://github.com/Quick/Nimble/issues/27).

For code that returns collections of complex objects without a strict
ordering, there is the `containElementSatisfying` matcher:

```swift
// Swift

struct Turtle {
    let color: String
}

let turtles: [Turtle] = functionThatReturnsSomeTurtlesInAnyOrder()

// This set of matchers passes regardless of whether the array is 
// [{color: "blue"}, {color: "green"}] or [{color: "green"}, {color: "blue"}]:

expect(turtles).to(containElementSatisfying({ turtle in
    return turtle.color == "green"
}))
expect(turtles).to(containElementSatisfying({ turtle in
    return turtle.color == "blue"
}, "that is a turtle with color 'blue'"))

// The second matcher will incorporate the provided string in the error message
// should it fail
```

> Note: in Swift, `containElementSatisfying` also has a variant that takes in an
async function.

```objc
// Objective-C

@interface Turtle : NSObject
@property (nonatomic, readonly, nonnull) NSString *color;
@end

@implementation Turtle 
@end

NSArray<Turtle *> * __nonnull turtles = functionThatReturnsSomeTurtlesInAnyOrder();

// This set of matchers passes regardless of whether the array is 
// [{color: "blue"}, {color: "green"}] or [{color: "green"}, {color: "blue"}]:

expect(turtles).to(containElementSatisfying(^BOOL(id __nonnull object) {
    return [[turtle color] isEqualToString:@"green"];
}));
expect(turtles).to(containElementSatisfying(^BOOL(id __nonnull object) {
    return [[turtle color] isEqualToString:@"blue"];
}));
```

For asserting on if the given `Comparable` value is inside of a `Range`, use the `beWithin` matcher.

```swift
// Swift

// Passes if 5 is within the range 1 through 10, inclusive
expect(5).to(beWithin(1...10))

// Passes if 5 is not within the range 2 through 4.
expect(5).toNot(beWithin(2..<5))
```
