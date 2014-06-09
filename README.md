Tailor
======

BDD in Swift - Alpha

Yeah, things are likely going to change. There are a lot of missing features right now.

Setup
-----

Currently, Tailor requires an underlying testing framework. Currently it uses XCTest.


Writing Tests
-------------

Since Swift doesn't directly allow initializers, you'll need to subclass ``TSSpec``:

    class TailorBootstrap : TSSpec {
        override class func defineBehaviors() {
            describe("cheese") {
                it("should be brown") {
                    expect(1).to(equalTo(1))
                }
            }
        }
    }


Of course, feel free to inherit from ``XCTestCase`` directly if you just want to use
matchers.


Matchers
--------

Matchers follow [Cedar's](https://github.com/pivotal/cedar) design. They're generic-based:

    expect(1).to(equalTo(1)) // equal() is used by Swift itself
    expect(1.2).to(beCloseTo(1.1, within: 1))
    
Certain comparable operators work as expected too:

    expect("foo") != "foo"
    expect(10) > 2

The ``expect`` function autocompletes to include ``file:`` and ``line:``, but these are optional.
The defaults will populate the current file and line.

Also, ``expect`` takes a lazily computed value (thanks to ``@auto_closure``). This makes handling
exceptions in-line (even though Swift doesn't support exceptions):

    var exception = NSException(name: "laugh", reason: "Lulz", userInfo: nil)
    expect(exception.raise()).to(raiseException(named: "laugh"))

Likewise, you can use trailing-closure style as needed:

    expect {
        "hello"
    }.to(equalTo("hello"))

The following matchers are currently implemented:

- equalTo (also == and != operators)
- beCloseTo
- beLessThan (also < operator)
- beLessThanOrEqualTo (also <= operator)
- beGreaterThan (also > operator)
- beGreaterThanOrEqualTo (also >= operator)
- raiseException
- beNil
- beTruthy: Non-nil optional values will match
- beFalsy: Note that nil / optionals will match too





