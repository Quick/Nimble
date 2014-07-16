Nimble
======

A Matcher Framework for Swift. Rewritten from scratch.

Currently, this **is not** part of the [Quick](https://github.com/quick-bdd/Quick) project.

Setup
-----

Currently, you must add this project as a subproject and link against the Nimble.framework.


Usage
-----

Matchers follow [Cedar's](https://github.com/pivotal/cedar) design. They're generic-based:

    import Nimble
    // ...
    expect(1).to(equal(1))
    expect(1.2).to(beCloseTo(1.1, within: 1))

Certain operators work as expected too:

    expect("foo") != "bar"
    expect(10) > 2

The ``expect`` function autocompletes to include ``file:`` and ``line:``, but these are optional.
The defaults will populate the current file and line.

Also, ``expect`` takes a lazily computed value. This makes it possible
to handle exceptions in-line (even though Swift doesn't support exceptions):

    var exception = NSException(name: "laugh", reason: "Lulz", userInfo: nil)
    expect(exception.raise()).to(raiseException(named: "laugh"))

Or you can use trailing-closure style as needed:

    expect {
        "hello"
    }.to(equalTo("hello"))

C primitives are allowed without any wrapping:

    let actual: CInt = 1
    let expectedValue: CInt = 1
    expect(actual).to(equal(expectedValue))

In fact, type inference is used to remove redudant type specifying:

    // both work
    expect(1 as CInt).to(equal(1))
    expect(1).to(equal(1 as CInt))

Asynchronous Expectations
-------------------------

Simply exchange ``to`` and ``toNot`` with ``toEventually`` and ``toEventuallyNot``:

    var value = 0
    dispatch_async(dispatch_get_main_queue()) {
        value = 1
    }
    expect(value).toEventually(equal(1))

This polls the expression inside ``expect(...)`` until the given expectation succeeds
within a 1 second. You can explicitly pass the ``timeout`` parameter:

    expect(value).toEventually(equal(1), timeout: 1)

If you prefer the callback-style that some testing frameworks do, use ``waitUntil``:

    waitUntil { done in
        // do some stuff that takes a while...
        NSThread.sleepForTimeInterval(0.5)
        done()
    }

And like the other asynchronous expectation, an optional timeout period can be provided:

    waitUntil(timeout: 10) { done in
        // do some stuff that takes a while...
        NSThread.sleepForTimeInterval(1)
        done()
    }

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
- ``beTruthy()``: Matches if the given value is not ``nil`` (for optionals) or ``false`` (for ``LogicValue`` supported types like ``bool``). Optional Bools are automatically unwrapped first.
- ``beFalsy()``: Matches if the given value is ``nil`` (for optionals) or ``false`` (for ``LogicValue`` supported types like ``bool``). Optional Bools are automatically unwrapped first.
- ``contain(items: T...)`` Matches if all of ``items`` are in the given container. Valid containers are Swift collections that have ``Equatable`` elements; ``NSArrays`` and ``NSSets``; and ``Strings`` - which use substring matching.
- ``beginWith(starting: T)`` Matches if ``starting`` is in beginning the given container. Valid containers are Swift collections that have ``Equatable`` elements; ``NSArrays``; and ``Strings`` - which use substring matching.
- ``endWith(ending: T)`` Matches if ``ending`` is at the end of the given container. Valid containers are Swift collections that have ``Equatable`` elements; ``NSArrays``; and ``Strings`` - which use substring matching.
- ``beIdenticalTo(expectedInstance: T)`` (also ``===`` and ``!==`` operators) Matches if ``expectedInstance`` has the same pointer address (identity equality) with the given value. Only works with Objective-C compatible objects.
- ``beAnInstanceOf(expectedClass: Class)`` Matches if the given object is the ``expectedClass`` using ``isMemberOfClass:``. Only works with Objective-C compatible objects.
- ``beAKindOf(expectedClass: Class)`` Matches if the given object is the ``expectedClass`` using ``isKindOfClass:``. Only works with Objective-C compatible objects.
- ``beEmpty()`` Matches if the given type contains nothing. Works with Strings and Collections from both Swift and Objective-C


Objective-C
===========

**Experimental Support**

Want to use this for Objective-C? The same syntax applies except you **must use Objective-C objects**:


    #import <Nimble/Nimble.h>
    // ...
    expect(@1).to(equal(@1));
    expect(@1.2).to(beCloseTo(@1.3).within(@0.5));
    expect(@[@1, @2]).to(contain(@1));

For exceptions, use ``expectAction``, which ignores the expression returned:

    expectAction([exception raise]).to(raiseException());


Writing Your Own Matchers
=========================

Most matchers can be defined using ``MatcherFunc``:

    func equal<T: Equatable>(expectedValue: T?) -> MatcherFunc<T> {
        return MatcherFunc { actualExpression, failureMessage in
            failureMessage.postfixMessage = "equal <\(expectedValue)>"
            return actualExpression.evaluate() == expectedValue
        }
    }

The return value inside ``MatcherFunc`` closure is a ``Bool`` that indicates success
or failure to match.

``actualExpression`` is a lazy, memoized closure around the value provided to
``expect(...)``.

Using Swift's generics, matchers can constrain the type of the actual value received
from ``expect(<actualValue>)`` by modifying the return type:

    @objc protocol FuzzyThing { } // objc for objc support (see Objective-C section below)
    // Only expect(fuzzyObject).to(beFuzzy()) is allowed by the compiler,
    // where fuzzyObject supports the FuzzyThing protocol or is nil.
    func beFuzzy() -> MatcherFunc<FuzzyThing?> {
        return MatcherFunc { actualExpression, failureMessage in
            // ...
        }
    }

Customizing Failure Messages
----------------------------

``failureMessage`` is a structure of the final expectation message to emit. If you
want to suppress emitting the actual value, you can nil out ``actualValue`` in your
matcher:

    failureMessage.actualValue = nil
    failureMessage.postfixMessage = "yo"
    // resulting error: expected to yo

Supporting Objective-C
----------------------

Since Swift generics cannot interop with Objective-C, you need to wrap your matchers
and expose them as regular C-functions. The common location is to place them in
``NMBObjCMatcher``:

    // Swift
    extension NMBObjCMatcher {
        class func beFuzzyMatcher() -> NMBObjCMatcher {
            return NMBObjCMatcher { actualBlock, failureMessage, location in
                let expr = Expression(expression: ({ actualBlock() as FuzzyThing? }), location: location)
                return beFuzzy().matches(expr, failureMessage: failureMessage)
            }
        }
    }

Afterwards, you'll probably want a nice interface for usage:

    // Objective-C
    FOUNDATION_EXPORT id<NMBMatcher> beFuzzy() {
        return [NMBObjCMatcher beFuzzyMatcher];
    }

When supporting Objective-C, make sure you handle ``nil`` appropriately. Like [Cedar](https://github.com/pivotal/cedar/issues/100),
**most matchers do not match with nil**. This is to prevent accidental nil-fallthroughs:

    expect(nil).to(equal(nil)); // fails

Which ``beNil()`` allows for explicit resolution:

    expect(nil).to(beNil()); // passes

