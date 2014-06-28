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

The following matchers are currently implemented:

- equal (also == and != operators)
- beCloseTo
- beLessThan (also < operator)
- beLessThanOrEqualTo (also <= operator)
- beGreaterThan (also > operator)
- beGreaterThanOrEqualTo (also >= operator)
- raiseException
- beNil
- beTruthy: Non-nil optional values will match
- beFalsy: nil and false will match
- contain
- beginWith
- endWith
- beIdenticalTo (also === and !== operators)

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





