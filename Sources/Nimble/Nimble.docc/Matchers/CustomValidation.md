# Custom Validation

```swift
// Swift

// passes if .succeeded is returned from the closure
expect {
    guard case .enumCaseWithAssociatedValueThatIDontCareAbout = actual else {
        return .failed(reason: "wrong enum case")
    }

    return .succeeded
}.to(succeed())

// passes if .failed is returned from the closure
expect {
    guard case .enumCaseWithAssociatedValueThatIDontCareAbout = actual else {
        return .failed(reason: "wrong enum case")
    }

    return .succeeded
}.notTo(succeed())
```

The `String` provided with `.failed()` is shown when the test fails.

> Warning: When using Polling Expectations be careful not to make state changes or run process intensive code since this closure will be ran many times.
