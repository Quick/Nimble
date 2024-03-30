#  Polling Expectations

In Nimble, it's easy to make expectations on values that are updated
asynchronously. These are called Polling Expectations, because they work by
continuously polling the Expectation.

## Forms of Polling Expectations

There are 4 forms of polling expectations: `toEventually`,
`toEventuallyNot`/`toNotEventually`, `toAlways`/`alwaysTo`, and `toNever`/`neverTo`.
These each have different behaviors for what they expect the matcher to return
until they stop polling.

For example, `toEventually` will run until the Matcher matches, while `toNever`
will run so long as the Matcher doesn't match. This makes them opposites.

> Warning: It is a very common mistake to assume that `toEventuallyNot` is the
opposite of `toEventually`. For example, if you're using a [Swift Fakes Spy](https://github.com/Quick/swift-fakes/blob/main/Sources/Fakes/Spy.swift),
you might be used to checking that it is called on a background thread by using
`expect(spy).toEventually(beCalled())`. If you want to check that a spy is not
called during some background behavior, you might be tempted to use `expect(spy).toEventuallyNot(beCalled())`.
All this will do is verify that, by the time the Expectation first runs, the spy
has not been called. At which point, that background behavior might not even have
run. The correct thing is to use `toNever`, as in `expect(spy).toNever(beCalled())`.

Polling form                        | Pass Duration | Expected Matcher Result
------------------------------------|---------------|------------------------
`toEventually`                      | Until pass    | to match
`toEventuallyNot`/`toNotEventually` | Until pass    | to not match
`toAlways`/`alwaysTo`               | Until fail    | to match
`toNever`/`neverTo`                 | Until fail    | to not match

### Verifying a Matcher will Eventually Match or stop Matching

To verify that a value eventually matches or stops matching through the length
of the timeout, use `toEventually` or `toEventuallyNot`/`toNotEventually`:

```swift
// Swift
DispatchQueue.main.async {
    ocean.add("dolphins")
    ocean.add("whales")
}
expect(ocean).toEventually(contain("dolphins", "whales"))
```

```objc
// Objective-C

dispatch_async(dispatch_get_main_queue(), ^{
    [ocean add:@"dolphins"];
    [ocean add:@"whales"];
});
expect(ocean).toEventually(contain(@"dolphins", @"whales"));
```

In the above example, `ocean` is constantly re-evaluated. If it ever
contains dolphins and whales, the expectation passes. If `ocean` still
doesn't contain them, even after being continuously re-evaluated for one
whole second, the expectation fails.

### Verifying a Matcher will Never or Always Match

You can also test that a value always or never matches throughout the length of the timeout. Use `toNever` and `toAlways` for this:

```swift
// Swift
ocean.add("dolphins")
expect(ocean).toAlways(contain("dolphins"))
expect(ocean).toNever(contain("hares"))
```

```objc
// Objective-C
[ocean add:@"dolphins"]
expect(ocean).toAlways(contain(@"dolphins"))
expect(ocean).toNever(contain(@"hares"))
```

### Behaviors of different forms of Polling

Fundamentally, the behaviors of the different types of polling (`toEventually`,
`toEventuallyNot`, `toAlways`, `toNever`) are about the duration of the polling,
and what they're looking for with regard to the Expectation.

For example, `toEventually` will run until the Expectation matches, while `toNever`
will run so long as the Expectation dosen't match. This effectively makes them
opposites.

> Warning: It is a very common mistake to assume that `toEventuallyNot` is the
opposite of `toEventually`. For example, if you're using a [Swift Fakes Spy](https://github.com/Quick/swift-fakes/blob/main/Sources/Fakes/Spy.swift),
you might be used to checking that it is called on a background thread by using
`expect(spy).toEventually(beCalled())`. If you want to check that a spy is not
called during some background behavior, you might be tempted to use `expect(spy).toEventuallyNot(beCalled())`.
All this will do is verify that, by the time the Expectation first runs, the spy
has not been called. At which point, that background behavior might not even have
run. The correct thing is to use `toNever`, as in `expect(spy).toNever(beCalled())`.

Polling form                        | Pass Duration | Expected Matcher Result
------------------------------------|---------------|------------------------
`toEventually`                      | Until pass    | to match
`toEventuallyNot`/`toNotEventually` | Until pass    | to not match
`toAlways`/`alwaysTo`               | Until fail    | to match
`toNever`/`neverTo`                 | Until fail    | to not match


### Waiting for a Callback to be Called

You can also provide a callback by using the `waitUntil` function:

```swift
// Swift

waitUntil { done in
    ocean.goFish { success in
        expect(success).to(beTrue())
        done()
    }
}
```

```objc
// Objective-C

waitUntil(^(void (^done)(void)){
    [ocean goFishWithHandler:^(BOOL success){
        expect(success).to(beTrue());
        done();
    }];
});
```

`waitUntil` also optionally takes a timeout parameter:

```swift
// Swift

waitUntil(timeout: .seconds(10)) { done in
    ocean.goFish { success in
        expect(success).to(beTrue())
        done()
    }
}
```

```objc
// Objective-C

waitUntilTimeout(10, ^(void (^done)(void)){
    [ocean goFishWithHandler:^(BOOL success){
        expect(success).to(beTrue());
        done();
    }];
});
```

Note: `waitUntil` triggers its timeout code on the main thread. Blocking the main
thread will cause Nimble to stop the run loop to continue. This can cause test
pollution for whatever incomplete code that was running on the main thread.
Blocking the main thread can be caused by blocking IO, calls to sleep(),
deadlocks, and synchronous IPC.

### Changing the Timeout and Polling Intervals

Sometimes it takes more than a second for a value to update. In those
cases, use the `timeout` parameter:

```swift
// Swift

// Waits three seconds for ocean to contain "starfish":
expect(ocean).toEventually(contain("starfish"), timeout: .seconds(3))

// Evaluate someValue every 0.2 seconds repeatedly until it equals 100, or fails if it timeouts after 5.5 seconds.
expect(someValue).toEventually(equal(100), timeout: .milliseconds(5500), pollInterval: .milliseconds(200))
```

```objc
// Objective-C

// Waits three seconds for ocean to contain "starfish":
expect(ocean).withTimeout(3).toEventually(contain(@"starfish"));
```

### Changing default Timeout and Poll Intervals

In some cases (e.g. when running on slower machines) it can be useful to modify
the default timeout and poll interval values. This can be done as follows:

```swift
// Swift

// Increase the global timeout to 5 seconds:
Nimble.PollingDefaults.timeout = .seconds(5)

// Slow the polling interval to 0.1 seconds:
Nimble.PollingDefaults.pollInterval = .milliseconds(100)
```

You can set these globally at test startup in two ways:

#### Quick

If you use [Quick](https://github.com/Quick/Quick), add a [`QuickConfiguration` subclass](https://github.com/Quick/Quick/blob/main/Documentation/en-us/ConfiguringQuick.md) which sets your desired `PollingDefaults`.

```swift
import Quick
import Nimble

class PollingConfiguration: QuickConfiguration {
    override class func configure(_ configuration: QCKConfiguration) {
        Nimble.PollingDefaults.timeout = .seconds(5)
        Nimble.PollingDefaults.pollInterval = .milliseconds(100)
    }
}
```

#### XCTest

If you use [XCTest](https://developer.apple.com/documentation/xctest), add an object that conforms to [`XCTestObservation`](https://developer.apple.com/documentation/xctest/xctestobservation) and implement [`testBundleWillStart(_:)`](https://developer.apple.com/documentation/xctest/xctestobservation/1500772-testbundlewillstart).

Additionally, you will need to register this observer with the [`XCTestObservationCenter`](https://developer.apple.com/documentation/xctest/xctestobservationcenter) at test startup. To do this, set the `NSPrincipalClass` key in your test bundle's Info.plist and implement a class with that same name.

For example

```xml
<!-- Info.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... -->
    <key>NSPrincipalClass</key>
    <string>MyTests.TestSetup</string>
</dict>
</plist>
```

```swift
// TestSetup.swift
import XCTest
import Nimble

@objc
class TestSetup: NSObject {
    override init() {
        XCTestObservationCenter.shared.register(PollingConfigurationTestObserver())
    }
}

class PollingConfigurationTestObserver: NSObject, XCTestObserver {
    func testBundleWillStart(_ testBundle: Bundle) {
        Nimble.PollingDefaults.timeout = .seconds(5)
        Nimble.PollingDefaults.pollInterval = .milliseconds(100)
    }
}
```

In Linux, you can implement `LinuxMain` to set the PollingDefaults before calling `XCTMain`.

## Using Polling Expectations in Async Tests

You can easily use `toEventually` or `toEventuallyNot` in async contexts as
well. You only need to add an `await` statement to the beginning of the line:

```swift
// Swift
DispatchQueue.main.async {
    ocean.add("dolphins")
    ocean.add("whales")
}
await expect(ocean).toEventually(contain("dolphens", "whiles"))
```

Starting in Nimble 12,  `toEventually` et. al. now also supports async
expectations. For example, the following test is now supported:

```swift
actor MyActor {
    private var counter = 0

    func access() -> Int {
        counter += 1
        return counter
    }
}

let subject = MyActor()
await expect { await subject.access() }.toEventually(equal(2))
```
