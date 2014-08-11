Nimble
======

A Matcher Framework for Swift and Objective-C.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [Usage](#usage)
  - [Asynchronous Expectations](#asynchronous-expectations)
  - [List of Builtin Matchers](#list-of-builtin-matchers)
  - [Using Nimble in Objective-C](#using-nimble-in-objective-c)
- [Writing Your Own Matchers](#writing-your-own-matchers)
  - [Customizing Failure Messages](#customizing-failure-messages)
  - [Supporting Objective-C](#supporting-objective-c)
- [Installing Nimble](#installing-nimble)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Usage
=====

Matchers follow [Cedar's](https://github.com/pivotal/cedar) design. They're generic-based:

```swift
import Nimble
// ...
expect(1).to(equal(1))
expect(1.2).to(beCloseTo(1.1, within: 1))
```

Certain operators work as expected too:

```swift
expect("foo") != "bar"
expect(10) > 2
```

The ``expect`` function autocompletes to include ``file:`` and ``line:``, but these are optional.
The defaults will populate the current file and line.

Also, ``expect`` takes a lazily computed value. This makes it possible
to handle exceptions in-line (even though Swift doesn't support exceptions):

```swift
var exception = NSException(name: "laugh", reason: "Lulz", userInfo: nil)
expect(exception.raise()).to(raiseException(named: "laugh"))
```

Or you can use trailing-closure style as needed:

```swift
expect {
    "hello"
}.to(equalTo("hello"))
```

C primitives are allowed without any wrapping:

```swift
let actual: CInt = 1
let expectedValue: CInt = 1
expect(actual).to(equal(expectedValue))
```

In fact, type inference is used to remove redudant type specifying:

```swift
// both work
expect(1 as CInt).to(equal(1))
expect(1).to(equal(1 as CInt))
```

Asynchronous Expectations
-------------------------

Simply exchange ``to`` and ``toNot`` with ``toEventually`` and ``toEventuallyNot``:

```swift
var value = 0
dispatch_async(dispatch_get_main_queue()) {
    value = 1
}
expect(value).toEventually(equal(1))
```

This polls the expression inside ``expect(...)`` until the given expectation succeeds
within a second. You can explicitly pass the ``timeout`` parameter:

```swift
expect(value).toEventually(equal(1), timeout: 1)
```

If you prefer the callback-style that some testing frameworks do, use ``waitUntil``:

```swift
waitUntil { done in
    // do some stuff that takes a while...
    NSThread.sleepForTimeInterval(0.5)
    done()
}
```

And like the other asynchronous expectation, an optional timeout period can be provided:

```swift
waitUntil(timeout: 10) { done in
    // do some stuff that takes a while...
    NSThread.sleepForTimeInterval(1)
    done()
}
```

List of Builtin Matchers
-------------------------

The following matchers are currently included with Nimble:

- ``equal(expectedValue)`` (also ``==`` and ``!=`` operators). Values must be ``Equatable``, ``Comparable``, or ``NSObjects``.
- ``beCloseTo(expectedValue, within: Double = 0.0001)``. Values must be coercable into a ``Double``.
- ``beLessThan(upperLimit)`` (also ``<`` operator). Values must be ``Comparable``.
- ``beLessThanOrEqualTo(upperLimit)`` (also ``<=`` operator). Values must be ``Comparable``.
- ``beGreaterThan(lowerLimit)`` (also ``>`` operator). Values must be ``Comparable``.
- ``beGreaterThanOrEqualTo(lowerLimit)`` (also ``>=`` operator). Values must be ``Comparable``,
- ``raiseException()`` Matches if the given closure raises an exception.
- ``raiseException(#named: String?)`` Matches if the given closure raises an exception with the given name.
- ``raiseException(#named: String?, #reason: String?)`` Matches if the given closure raises an exception with the given name and reason.
- ``beNil()`` Matches if the given value is ``nil``.
- ``beTruthy()``: Matches if the given value is ``true`` (for ``BooleanType`` supported types like ``bool``).
- ``beFalsy()``: Matches if the given value is ``false`` (for ``BooleanType`` supported types like ``bool``).
- ``contain(items: T...)`` Matches if all of ``items`` are in the given container. Valid containers are Swift collections that have ``Equatable`` elements; ``NSArrays`` and ``NSSets``; and ``Strings`` - which use substring matching.
- ``beginWith(starting: T)`` Matches if ``starting`` is in beginning the given container. Valid containers are Swift collections that have ``Equatable`` elements; ``NSArrays``; and ``Strings`` - which use substring matching.
- ``endWith(ending: T)`` Matches if ``ending`` is at the end of the given container. Valid containers are Swift collections that have ``Equatable`` elements; ``NSArrays``; and ``Strings`` - which use substring matching.
- ``beIdenticalTo(expectedInstance: T)`` (also ``===`` and ``!==`` operators) Matches if ``expectedInstance`` has the same pointer address (identity equality) with the given value. Only works with Objective-C compatible objects.
- ``beAnInstanceOf(expectedClass: Class)`` Matches if the given object is the ``expectedClass`` using ``isMemberOfClass:``. Only works with Objective-C compatible objects.
- ``beAKindOf(expectedClass: Class)`` Matches if the given object is the ``expectedClass`` using ``isKindOfClass:``. Only works with Objective-C compatible objects.
- ``beEmpty()`` Matches if the given type contains nothing. Works with Strings and Collections from both Swift and Objective-C

Using Nimble in Objective-C
---------------------------

Want to use this for Objective-C? The same syntax applies except you **must use Objective-C objects**:

```objc
#import <Nimble/Nimble.h>
// ...
expect(@1).to(equal(@1));
expect(@1.2).to(beCloseTo(@1.3).within(@0.5));
expect(@[@1, @2]).to(contain(@1));
```

For exceptions, use ``expectAction``, which ignores the expression returned:

```objc
expectAction([exception raise]).to(raiseException());
```


Writing Your Own Matchers
=========================

Most matchers can be defined using ``MatcherFunc``:

```swift
func equal<T: Equatable>(expectedValue: T?) -> MatcherFunc<T> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(expectedValue)>"
        return actualExpression.evaluate() == expectedValue
    }
}
```

The return value inside ``MatcherFunc`` closure is a ``Bool`` that indicates success
or failure to match.

``actualExpression`` is a lazy, memoized closure around the value provided to
``expect(...)``.

Using Swift's generics, matchers can constrain the type of the actual value received
from ``expect(<actualValue>)`` by modifying the return type:

```swift
@objc protocol FuzzyThing { } // @objc for objc support (see Objective-C section below)
// Only expect(fuzzyObject).to(beFuzzy()) is allowed by the compiler,
// where fuzzyObject supports the FuzzyThing protocol or is nil.
func beFuzzy() -> MatcherFunc<FuzzyThing?> {
    return MatcherFunc { actualExpression, failureMessage in
        // ...
    }
}
```

Customizing Failure Messages
----------------------------

``failureMessage`` is a structure of the final expectation message to emit. If you
want to suppress emitting the actual value, you can nil out ``actualValue`` in your
matcher:

```swift
failureMessage.actualValue = nil
failureMessage.postfixMessage = "yo"
// resulting error: expected to yo
```

Supporting Objective-C
----------------------

Since Swift generics cannot interop with Objective-C, you need to wrap your matchers
and expose them as regular C-functions. The common location is to place them in
``NMBObjCMatcher``:

```swift
// Swift
extension NMBObjCMatcher {
    class func beFuzzyMatcher() -> NMBObjCMatcher {
        return NMBObjCMatcher { actualBlock, failureMessage, location in
            let expr = Expression(expression: ({ actualBlock() as FuzzyThing? }), location: location)
            return beFuzzy().matches(expr, failureMessage: failureMessage)
        }
    }
}
```

Afterwards, you'll probably want a nice interface for usage:

```objc
// Objective-C
FOUNDATION_EXPORT id<NMBMatcher> beFuzzy() {
    return [NMBObjCMatcher beFuzzyMatcher];
}
```

When supporting Objective-C, make sure you handle ``nil`` appropriately. Like [Cedar](https://github.com/pivotal/cedar/issues/100),
**most matchers do not match with nil**. This is to prevent accidental nil-fallthroughs:

```objc
expect(nil).to(equal(nil)); // fails
```

Which ``beNil()`` allows for explicit resolution:

```objc
expect(nil).to(beNil()); // passes
```

Installing Nimble
=================

Currently, you must add this project as a subproject and link against the Nimble.framework.

See [How to Install Quick](https://github.com/Quick/Quick#how-to-install-quick)
which walks through how to set up Quick and Nimble. Simply ignoring the Quick setup and just
follow the Nimble setup.

