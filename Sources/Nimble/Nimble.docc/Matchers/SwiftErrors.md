# Swift Error Handling

You can use the `throwError` matcher to check if an error is thrown.

```swift
// Swift

// Passes if 'somethingThatThrows()' throws an 'Error':
expect { try somethingThatThrows() }.to(throwError())

// Passes if 'somethingThatThrows()' throws an error within a particular domain:
expect { try somethingThatThrows() }.to(throwError { (error: Error) in
    expect(error._domain).to(equal(NSCocoaErrorDomain))
})

// Passes if 'somethingThatThrows()' throws a particular error enum case:
expect { try somethingThatThrows() }.to(throwError(NSCocoaError.PropertyListReadCorruptError))

// Passes if 'somethingThatThrows()' throws an error of a particular type:
expect { try somethingThatThrows() }.to(throwError(errorType: NimbleError.self))
```

When working directly with `Error` values, using the `matchError` matcher
allows you to perform certain checks on the error itself without having to
explicitly cast the error.

The `matchError` matcher allows you to check whether or not the error:

- is the same _type_ of error you are expecting.
- represents a particular error value that you are expecting.

This can be useful when using `Result` or `Promise` types, for example.

```swift
// Swift

let actual: Error = ...

// Passes if 'actual' represents any error value from the NimbleErrorEnum type:
expect(actual).to(matchError(NimbleErrorEnum.self))

// Passes if 'actual' represents the case 'timeout' from the NimbleErrorEnum type:
expect(actual).to(matchError(NimbleErrorEnum.timeout))

// Passes if 'actual' contains an NSError equal to the one provided:
expect(actual).to(matchError(NSError(domain: "err", code: 123, userInfo: nil)))
```

> Note: This feature is only available in Swift.
