# Using `require` to demand that a matcher pass before continuing

Nimble 13.1 added the ``require`` dsl to complement ``expect``. `require`
looks similar to `expect` and works with matchers just like `expect` does. The
difference is that `require` requires that the matcher passes - if the matcher
doesn't pass, then `require` will throw an error. Additionally, if `require`
does pass, then it'll return the result of running the expression.

For example, in testing a function that returns an array, you might need to
first guarantee that there are exactly 3 items in the array before continuing
to assert on it. Instead of writing code that needlessly duplicates an assertion
and a conditional like so:

```swift
let collection = myFunction()
expect(collection).to(haveCount(3))
guard collection.count == 3 else { return }
// ...
```

You can replace that with:

```swift
let collection = try require(myFunction()).to(haveCount(3))
// ...
```

## Polling with `require`.

Because `require` does everything you can do with `expect`, you can also use
`require` to <doc:PollingExpectations> using `toEventually`,
`eventuallyTo`, `toEventuallyNot`, `toNotEventually`, `toNever`, `neverTo`,
`toAlways`, and `alwaysTo`. These work exactly the same as they do when using
`expect`, except that they throw if they fail, and they return the value of the
expression when they pass.

## Using `require` with Async expressions and Async matchers

`require` also works with both async expressions
(`require { await someExpression() }.to(...)`), and async matchers
(`require().to(someAsyncMatcher())`).

Note that to prevent compiler confusion,
you cannot use `require` with async autoclosures. That is,
`require(await someExpression())` will not compile. You can instead either
make the closure explicit (`require { await someExpression() }`), or use the
`requirea` function, which does accept autoclosures.
Similarly, if you ever wish to use the sync version of `require` when the
compiler is trying to force you to use the async version, you can use the
`requires` function, which only allows synchronous expressions.

## Using `unwrap` to replace `require(...).toNot(beNil())`

It's very common to require that a value not be nil. Instead of writing
`try require(...).toNot(beNil())`, Nimble provides the `unwrap` function. This
expression throws an error if the expression evaluates to nil, or returns the
non-nil result when it passes. For example:

```swift
let value = try unwrap(nil as Int?) // throws
let value = try unwrap(1 as Int?) // returns 1
```

Additionally, there is also the `pollUnwrap` function, which aliases to
`require(...).toEventuallyNot(beNil())`. This is extremely useful for verifying
that a value that is updated on a background thread was eventually set to a
non-nil value.

Note: As with `require`, there are `unwraps`, `unwrapa`, `pollUnwraps`, and
`pollUnwrapa` variants for allowing you to use autoclosures specifically with
synchronous or asynchronous code.

## Throwing a Custom Error from Require

By default, if the matcher fails in a `require`, then a ``RequireError`` will be
thrown. You can override this behavior and throw a custom error by passing a
non-nil `Error` value to the `customError` parameter:

```swift
try require(1).to(equal(2)) // throws a `RequireError`
try require(customError: MyCustomError(), 1).to(equal(2)) // throws a `MyCustomError`
```
