import XCTest
@testable import Nimbletest

// This is the entry point for NimbleTests on Linux

XCTMain([
    // AsynchronousTests(),
    SynchronousTest(),
    UserDescriptionTest(),

    // Matchers
    AllPassTest(),
    // BeAKindOfTest(),
    BeAnInstanceOfTest(),
    BeCloseToTest(),
    BeginWithTest(),
    BeGreaterThanOrEqualToTest(),
    BeGreaterThanTest(),
    BeIdenticalToObjectTest(),
    BeIdenticalToTest(),
    BeLessThanOrEqualToTest(),
    BeLessThanTest(),
    BeTruthyTest(),
    BeTrueTest(),
    BeFalsyTest(),
    BeFalseTest(),
    BeNilTest(),
    ContainTest(),
    EndWithTest(),
    EqualTest(),
    HaveCountTest(),
    // MatchTest(),
    // RaisesExceptionTest(),
    ThrowErrorTest(),
    SatisfyAnyOfTest(),
    PostNotificationTest(),
])
