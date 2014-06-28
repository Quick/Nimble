Kick
======

A Matchers Framework for Swift.

Setup
-----

Currently, you must add this project as a subproject and link against the Kick.framework.


Usage
-----

Matchers follow [Cedar's](https://github.com/pivotal/cedar) design. They're generic-based:

    expect(1).to(equal(1))
    expect(1.2).to(beCloseTo(1.1, within: 1))
    
Certain comparable operators work as expected too:

    expect("foo") != "foo"
    expect(10) > 2

The ``expect`` function autocompletes to include ``file:`` and ``line:``, but these are optional.
The defaults will populate the current file and line.

Also, ``expect`` takes a lazily computed value (thanks to ``@auto_closure``). This makes it possible
to handle exceptions in-line (even though Swift doesn't support exceptions):

    var exception = NSException(name: "laugh", reason: "Lulz", userInfo: nil)
    expect(exception.raise()).to(raiseException(named: "laugh"))

Or you can use trailing-closure style as needed:

    expect {
        "hello"
    }.to(equalTo("hello"))

Kick uses generics, so C primitives are allowed without any wrapping:

    expect(1 as CInt).to(equal(1 as CInt))

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

This polls the expression inside ``expect(...)`` until the given expectation succeeds by
advancing the run loop.

List of Builtin Matchers
-------------------------

The following matchers are currently included with Kick:

- ``equal(expectedValue)`` (also ``==`` and ``!=`` operators). Values must be ``Equatable``, ``Comparable``, or ``NSObjects``.
- ``beCloseTo(expectedValue, within: Double = 0.0001)``. Values must be coercable into a ``Double``.
- ``beLessThan(upperLimit)`` (also ``<`` operator). Values must be ``Comparable``.
- ``beLessThanOrEqualTo(upperLimit)`` (also ``<=`` operator). Values must be ``Comparable``.
- ``beGreaterThan(lowerLimit)`` (also ``>`` operator). Values must be ``Comparable``.
- ``beGreaterThanOrEqualTo(lowerLimit)`` (also ``>=`` operator). Values must be ``Comparable``,
- ``raiseException()`` Matches if the given closure raises an exception.
- ``raiseException(#named: String)`` Matches if the given closure raises an exception with the given name.
- ``raiseException(#named: String, #reason: String)`` Matches if the given closure raises an exception with the given name and reason.
- ``beNil()`` Matches if the given value is ``nil``.
- ``beTruthy()``: Matches if the given value is not ``nil`` (for optionals) or ``false`` (for ``LogicValue`` supported types like ``bool``). Optional Bools are automatically unwrapped first.
- ``beFalsy()``: Matches if the given value is ``nil`` (for optionals) or ``false`` (for ``LogicValue`` supported types like ``bool``). Optional Bools are automatically unwrapped first.
- ``contain(items: T...)`` Matches if all of ``items`` are in the given container. Valid containers are ``Sequences`` that have ``Equatable`` elements; ``NSArrays`` and ``NSSets``; and ``Strings`` - which use substring matching.
- ``beginWith(starting: T)`` Matches if ``starting`` is in beginning the given container. Valid containers are ``Sequences`` that have ``Equatable`` elements; ``NSArrays``; and ``Strings`` - which use substring matching.
- ``endWith(ending: T)`` Matches if ``starting`` is in beginning the given container. Valid containers are ``Sequences`` that have ``Equatable`` elements; ``NSArrays``; and ``Strings`` - which use substring matching.
- ``beIdenticalTo(expectedInstance: T)`` (also ``===`` and ``!==`` operators) Matches if ``expectedInstance`` has the same pointer address (identity equality) with the given value. Only works on Objective-C compatible objects.
- ``beAnInstanceOf(expectedClass: Class)`` Matches if the given object is the ``expectedClass``. Only works for Objective-C classes.

Writing Your Own Matchers
=========================

Most matchers can be defined using the ``MatcherFunc`` helper:

    func equal<T: Equatable>(expectedValue: T?) -> FuncMatcherWrapper<T> {
        return MatcherFunc { actualExpression, failureMessage in
            failureMessage.postfixMessage = "equal <\(expectedValue)>"
            return actualExpression.evaluate() == expectedValue
        }
    }

The return value inside ``MatcherFunc`` is a ``Bool`` that indicates success or failure
to match.

``actualExpression`` is a lazy, memoized closure around the value provided to
``expect(...)``.

Using Swift's generics, matchers can constrain the type of the actual value received
from ``expect(<actualValue>)`` by modifying the return type:

    protocol FuzzyThing { }
    // Only expect(fuzzyObject).to(beFuzzy()) is allowed by the compiler,
    // where fuzzyObject supports the FuzzyThing protocol.
    func beFuzzy() -> FuncMatcherWrapper<FuzzyThing> {
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


