# Strings

You can check strings using the `contain`, `beginWith`, `endWith`, `beEmpty`,
and `match` matchers.

The `contain`, `beginWith`, `endWith`, and `beEmpty` operate using substrings,
while the `match` matcher checks if the string matches the given regular
expression.

```swift
// Swift

// Passes if 'actual' contains 'substring':
expect(actual).to(contain(substring))

// Passes if 'actual' begins with 'prefix':
expect(actual).to(beginWith(prefix))

// Passes if 'actual' ends with 'suffix':
expect(actual).to(endWith(suffix))

// Passes if 'actual' represents the empty string, "":
expect(actual).to(beEmpty())

// Passes if 'actual' matches the regular expression defined in 'expected':
expect(actual).to(match(expected))
```

```objc
// Objective-C

// Passes if 'actual' contains 'substring':
expect(actual).to(contain(expected));

// Passes if 'actual' begins with 'prefix':
expect(actual).to(beginWith(prefix));

// Passes if 'actual' ends with 'suffix':
expect(actual).to(endWith(suffix));

// Passes if 'actual' represents the empty string, "":
expect(actual).to(beEmpty());

// Passes if 'actual' matches the regular expression defined in 'expected':
expect(actual).to(match(expected))
```
