# ``Nimble``

**Nimble** is a testing framework for verifying the outcomes and Swift or Objective-C expressions.

## Overview

Nimble provides 4 things:

- A way to verify expressions using a natural, easily understood language.
- **Matchers**, or functions to check the Behavior of an expression.
- Means of requiring an **Expectation** - an expression-matcher combination - to pass before continuing.
- A way to check expressions that change over time.

## Terms

- term Expression: A Swift or Objective-C bit of code. For example `1 + 1`.
- term Behavior: A result or side effect of an expression. For example
`print("hello")` has a behavior of writing "hello\n" to standard output, while
`1 + 1` has a behavior of returning 2.
- term Matcher: A function from Nimble which checks an Expression's Behavior.
- term Expectation: An Expression combined with an Expression. For example,
`expect(1 + 1).to(equal(2))` is an Expectation.
- term Polling Expectation: An expectation that is continuously polled until it
finishes.
- term Requirement: An Expectation that must pass before continuing. These are
usually defined using `require` instead of `expect`, though there are shortcuts
such as ``unwrap(file:line:customError:_:)-5q9f3`` and ``pollUnwrap(file:line:_:)-4ddnp``.

## Topics

### Guides

- <doc:Background>
- <doc:Expectations>
- <doc:Concurrency>
- <doc:PollingExpectations>
- <doc:ObjectiveC>
- <doc:Require>
- <doc:WritingCustomMatchers>

### Matchers

Nimble includes a wide variety of matcher functions.

- <doc:TypeChecking>
- <doc:Equivalence>
- <doc:Identity>
- <doc:Comparisons>
- <doc:Truthiness>
- <doc:SwiftAssertions>
- <doc:SwiftErrors>
- <doc:Exceptions>
- <doc:Strings>
- <doc:Notifications>
- <doc:Result>
- <doc:GroupsOfMatchers>
- <doc:CustomValidation>
- <doc:Map>
- <doc:Collections>
