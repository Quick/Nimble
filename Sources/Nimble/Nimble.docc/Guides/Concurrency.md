#  Swift Concurrency (Async/Await) Support

Nimble makes it easy to await for an async function to complete.

Simply pass the async function in to `expect`:

```swift
// Swift
await expect { await aFunctionReturning1() }.to(equal(1))
```

The async function is awaited on first, before passing it to the matcher. This
enables the matcher to run synchronous code like before, without caring about
whether the value it's processing was abtained async or not.

Async support is Swift-only, and it requires that you execute the test in an
async context. For XCTest, this is as simple as marking your test function with
`async`. If you use Quick, all tests in Quick 6 are executed in an async context.
In Quick 7 and later, only tests that are in an `AsyncSpec` subclass will be
executed in an async context.

To avoid a compiler errors when using synchronous `expect` in asynchronous contexts,
`expect` with async expressions does not support autoclosures. However, the `expecta`
(expect async) function is provided as an alternative, which does support autoclosures.

```swift
// Swift
await expecta(await aFunctionReturning1()).to(equal(1)))
```

Similarly, if you're ever in a situation where you want to force the compiler to
produce a `SyncExpectation`, you can use the `expects` (expect sync) function to
produce a `SyncExpectation`. Like so:

```swift
// Swift
expects(someNonAsyncFunction()).to(equal(1)))

expects(await someAsyncFunction()).to(equal(1)) // Compiler error: 'async' call in an autoclosure that does not support concurrency
```

### Async Matchers

In addition to asserting on async functions prior to passing them to a
synchronous matcher, you can also write matchers that directly take in an
async value. These are called `AsyncMatcher`s. This is most obviously useful
when directly asserting against an actor. In addition to writing your own
async matchers, Nimble currently ships with async versions of the following
matchers:

- ``allPass``
- ``containElementSatisfying``
- ``satisfyAllOf`` and the ``&&`` operator overload accept both `AsyncMatcher` and
  synchronous ``Matcher``s.
- ``satisfyAnyOf`` and the ``||`` operator overload accept both ``AsyncMatcher`` and
  synchronous ``Matcher``s.

Note: Swift Concurrency support is different than the `toEventually`/`toEventuallyNot` feature described in <doc:PollingExpectations>.
Polling Expectations works by continuously polling
the `Expectation` until it passes. As described here, Nimble's Swift
Concurrency support is about waiting for an expression to finish.

It is certainly possible to use Polling Expectations with async/await, as the
result of a concurrent Expectation can certainly change with time.
