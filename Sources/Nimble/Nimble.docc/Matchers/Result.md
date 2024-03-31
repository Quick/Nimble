# Result

You can check the contents of a `Result` type using the `beSuccess` or
`beFailure` matchers.

```swift
// Swift
let aResult: Result<String, Error> = .success("Hooray") 

// passes if result is .success
expect(aResult).to(beSuccess()) 

// passes if result value is .success and validates Success value
expect(aResult).to(beSuccess { value in
    expect(value).to(equal("Hooray"))
})

// passes if the result value is .success and if the Success value matches
// the passed-in matcher (in this case, `equal`)
expect(aResult).to(beSuccess(equal("Hooray")))

// passes if the result value is .success and if the Success value equals
// the passed-in value (only available when the Success value is Equatable)
expect(aResult).to(beSuccess("Hooray"))


enum AnError: Error {
    case somethingHappened
}
let otherResult: Result<String, AnError> = .failure(.somethingHappened) 

// passes if result is .failure
expect(otherResult).to(beFailure()) 

// passes if result value is .failure and validates error
expect(otherResult).to(beFailure { error in
    expect(error).to(matchError(AnError.somethingHappened))
}) 

// passes if the result value is .failure and if the Failure value matches
// the passed-in matcher (in this case, `matchError`)
expect(otherResult).to(beFailure(matchError(AnError.somethingHappened)))
```

> Note: This matcher is only available in Swift.
