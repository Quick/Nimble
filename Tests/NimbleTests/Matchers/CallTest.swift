import XCTest
import Nimble

class CallTest : XCTestCase {

    class TestClass : CallRecorder {
        var called = (functionList: [String](), argumentsList: [[GloballyEquatable]]())

        func doStuff() {
            self.recordCall()
        }

        func doStuffWith(string: String) {
            self.recordCall(arguments: string)
        }

        func doThingsWith(string: String, int: Int) {
            self.recordCall(arguments: string, int)
        }
    }

    func testCall() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuff()

        // then
        expect(testClass).to(call("doStuff()"))
        expect(testClass).toNot(call("doThings()"))
    }

    func testCallFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "swift")

        // when
        let toFailingTest = { expect(testClass).to(call("doStuff()")) }
        let toNotFailingTest = { expect(testClass).toNot(call("doStuffWith(string:)")) }
        let nilFailingTest = { expect(nil as TestClass?).to(call("doStuff()")) }

        // then
        let toExpectedMessage = "expected to call <doStuff()> from TestClass, got <doStuffWith(string:) with swift>"
        failsWithErrorMessage(toExpectedMessage) { toFailingTest() }

        let toNotExpectedMessage = "expected to not call <doStuffWith(string:)> from TestClass, got <doStuffWith(string:) with swift>"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to call function, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }

    func testCallWithCount() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuffWith(string: "string")

        // then
        expect(testClass).to(call("doStuffWith(string:)", countSpecifier: .Exactly(1)))
        expect(testClass).toNot(call("doStuffWith(string:)", countSpecifier: .Exactly(2)))
    }

    func testCallWithCountFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuff()

        // when
        let toFailingTest1 = { expect(testClass).to(call("doDifferentStuff()", countSpecifier: .Exactly(1))) }
        let toFailingTest2 = { expect(testClass).to(call("doStuff()", countSpecifier: .Exactly(2))) }
        let toNotFailingTest = { expect(testClass).toNot(call("doStuff()", countSpecifier: .Exactly(1))) }
        let nilFailingTest = { expect(nil as TestClass?).to(call("doStuff()", countSpecifier: .Exactly(1))) }

        // then
        let toExpectedMessage1 = "expected to call <doDifferentStuff()> from TestClass exactly 1 time, got <doStuff()>"
        failsWithErrorMessage(toExpectedMessage1) { toFailingTest1() }

        let toExpectedMessage2 = "expected to call <doStuff()> from TestClass exactly 2 times, got <doStuff()>"
        failsWithErrorMessage(toExpectedMessage2) { toFailingTest2() }

        let toNotExpectedMessage = "expected to not call <doStuff()> from TestClass exactly 1 time, got <doStuff()>"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to call function count times, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }

    func testCallWithAtLeast() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuffWith(string: "string")

        // then
        expect(testClass).to(call("doStuffWith(string:)", countSpecifier: .AtLeast(1)))
        expect(testClass).toNot(call("doStuffWith(string:)", countSpecifier: .AtLeast(2)))
    }

    func testCallWithAtLeastFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        testClass.doStuff()

        // when
        let toFailingTest = { expect(testClass).to(call("doStuff()", countSpecifier: .AtLeast(3))) }
        let toNotFailingTest = { expect(testClass).toNot(call("doStuff()", countSpecifier: .AtLeast(2))) }
        let nilFailingTest = { expect(nil as TestClass?).to(call("doStuff()", countSpecifier: .AtLeast(2))) }

        // then
        let toExpectedMessage = "expected to call <doStuff()> from TestClass at least 3 times, got <doStuff()>, <doStuff()>"
        failsWithErrorMessage(toExpectedMessage) { toFailingTest() }

        let toNotExpectedMessage = "expected to not call <doStuff()> from TestClass at least 2 times, got <doStuff()>, <doStuff()>"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to call function at least count times, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }

    func testCallWithAtMost() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuffWith(string: "string")

        // then
        expect(testClass).to(call("doStuffWith(string:)", countSpecifier: .AtMost(1)))
        expect(testClass).toNot(call("doStuffWith(string:)", countSpecifier: .AtMost(0)))
    }

    func testCallWithAtMostFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        testClass.doStuff()
        testClass.doStuff()
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")

        // when
        let toFailingTest1 = { expect(testClass).to(call("doStuffWith(string:)", countSpecifier: .AtMost(1))) }
        let toFailingTest2 = { expect(testClass).to(call("doStuff()", countSpecifier: .AtMost(2))) }
        let toNotFailingTest = { expect(testClass).toNot(call("doStuff()", countSpecifier: .AtMost(4))) }
        let nilFailingTest = { expect(nil as TestClass?).to(call("doStuff()", countSpecifier: .AtMost(1))) }

        // then
        let got = "got <doStuff()>, <doStuff()>, <doStuff()>, <doStuffWith(string:) with quick>, <doStuffWith(string:) with nimble>"
        let toExpectedMessage1 = "expected to call <doStuffWith(string:)> from TestClass at most 1 time, \(got)"
        failsWithErrorMessage(toExpectedMessage1) { toFailingTest1() }

        let toExpectedMessage2 = "expected to call <doStuff()> from TestClass at most 2 times, \(got)"
        failsWithErrorMessage(toExpectedMessage2) { toFailingTest2() }

        let toNotExpectedMessage = "expected to not call <doStuff()> from TestClass at most 4 times, \(got)"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to call function at most count times, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }

    func testCallWithArguments() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuffWith(string: "quick")
        testClass.doThingsWith(string: "nimble", int: 5)

        // then
        expect(testClass).to(call("doStuffWith(string:)", withArguments: "quick"))
        expect(testClass).toNot(call("doStuffWith(string:)", withArguments: "nimble"))
        expect(testClass).to(call("doThingsWith(string:int:)", withArguments: "nimble", 5))
        expect(testClass).toNot(call("doThingsWith(string:int:)", withArguments: "nimble", 10))
    }

    func testCallWithArgumentsFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "nimble")

        // when
        let toFailingTest = { expect(testClass).to(call("doStuffWith(string:)", withArguments: "quick")) }
        let toNotFailingTest = { expect(testClass).toNot(call("doStuffWith(string:)", withArguments: "nimble")) }
        let nilFailingTest = { expect(nil as TestClass?).to(call("doStuffWith(string:)", withArguments: "call matcher")) }

        // then
        let toExpectedMessage = "expected to call <doStuffWith(string:)> from TestClass with quick, got <doStuffWith(string:) with nimble>"
        failsWithErrorMessage(toExpectedMessage) { toFailingTest() }

        let toNotExpectedMessage = "expected to not call <doStuffWith(string:)> from TestClass with nimble, got <doStuffWith(string:) with nimble>"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to call function with arguments, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }

    func testCallWithArgumentsAndCount() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        testClass.doThingsWith(string: "nimble", int: 5)

        // then
        expect(testClass).to(call("doStuffWith(string:)", withArguments: "nimble", countSpecifier: .Exactly(1)))
        expect(testClass).toNot(call("doStuffWith(string:)", withArguments: "nimble", countSpecifier: .Exactly(2)))
        expect(testClass).to(call("doThingsWith(string:int:)", withArguments: "nimble", 5, countSpecifier: .Exactly(1)))
        expect(testClass).toNot(call("doThingsWith(string:int:)", withArguments: "nimble", 5, countSpecifier: .Exactly(2)))
    }

    func testCallWithArgumentsAndCountFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")

        // when
        let toFailingTest1 = { expect(testClass).to(call("doDifferentStuffWith(string:)", withArguments: "swift", countSpecifier: .Exactly(1))) }
        let toFailingTest2 = { expect(testClass).to(call("doStuffWith(string:)", withArguments: "nimble", countSpecifier: .Exactly(2))) }
        let toNotFailingTest = { expect(testClass).toNot(call("doStuffWith(string:)", withArguments: "nimble", countSpecifier: .Exactly(1))) }
        let nilFailingTest = { expect(nil as TestClass?).to(call("doStuffWith(string:)", withArguments: "call matcher", countSpecifier: .Exactly(1))) }

        // then
        let got = "got <doStuffWith(string:) with quick>, <doStuffWith(string:) with nimble>"

        let toExpectedMessage1 = "expected to call <doDifferentStuffWith(string:)> from TestClass with swift exactly 1 time, \(got)"
        failsWithErrorMessage(toExpectedMessage1) { toFailingTest1() }

        let toExpectedMessage2 = "expected to call <doStuffWith(string:)> from TestClass with nimble exactly 2 times, \(got)"
        failsWithErrorMessage(toExpectedMessage2) { toFailingTest2() }

        let toNotExpectedMessage = "expected to not call <doStuffWith(string:)> from TestClass with nimble exactly 1 time, \(got)"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to call function with arguments count times, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }

    func testCallWithArgumentsAndAtLeast() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")

        // then
        expect(testClass).to(call("doStuffWith(string:)", withArguments: "nimble", countSpecifier: .AtLeast(1)))
        expect(testClass).toNot(call("doStuffWith(string:)", withArguments: "nimble", countSpecifier: .AtLeast(2)))
    }

    func testCallWithArgumentsAndAtLeastFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        testClass.doStuffWith(string: "nimble")

        // when
        let toFailingTest = { expect(testClass).to(call("doDifferentStuffWith(string:)", withArguments: "quick", countSpecifier: .AtLeast(2))) }
        let toNotFailingTest = { expect(testClass).toNot(call("doStuffWith(string:)", withArguments: "nimble", countSpecifier: .AtLeast(2))) }
        let nilFailingTest = { expect(nil as TestClass?).to(call("doStuffWith(string:)", withArguments: "call matcher", countSpecifier: .AtLeast(2))) }

        // then
        let got = "got <doStuffWith(string:) with quick>, <doStuffWith(string:) with nimble>, <doStuffWith(string:) with nimble>"

        let toExpectedMessage = "expected to call <doDifferentStuffWith(string:)> from TestClass with quick at least 2 times, \(got)"
        failsWithErrorMessage(toExpectedMessage) { toFailingTest() }

        let toNotExpectedMessage = "expected to not call <doStuffWith(string:)> from TestClass with nimble at least 2 times, \(got)"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to call function with arguments at least count times, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }

    func testCallWithArgumentsAndAtMost() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")

        // then
        expect(testClass).to(call("doStuffWith(string:)", withArguments: "nimble", countSpecifier: .AtMost(1)))
        expect(testClass).toNot(call("doStuffWith(string:)", withArguments: "nimble", countSpecifier: .AtMost(0)))
    }

    func testCallWithArgumentsAndAtMostFailureMessage() {
        // given
        let testClass = TestClass()
        testClass.doThingsWith(string: "call matcher", int: 5)
        testClass.doThingsWith(string: "call matcher", int: 5)
        testClass.doStuffWith(string: "swift")
        testClass.doStuffWith(string: "swift")
        testClass.doStuffWith(string: "swift")

        // when
        let toFailingTest1 = { expect(testClass).to(call("doThingsWith(string:int:)", withArguments: "call matcher", 5, countSpecifier: .AtMost(1))) }
        let toFailingTest2 = { expect(testClass).to(call("doStuffWith(string:)", withArguments: "swift", countSpecifier: .AtMost(2))) }
        let toNotFailingTest = { expect(testClass).toNot(call("doStuffWith(string:)", withArguments: "swift", countSpecifier: .AtMost(4))) }
        let nilFailingTest = { expect(nil as TestClass?).to(call("doStuffWith(string:)", withArguments: "swift", countSpecifier: .AtMost(1))) }

        // then
        let got = "got <doThingsWith(string:int:) with call matcher, 5>, <doThingsWith(string:int:) with call matcher, 5>, <doStuffWith(string:) with swift>, <doStuffWith(string:) with swift>, <doStuffWith(string:) with swift>"

        let toExpectedMessage1 = "expected to call <doThingsWith(string:int:)> from TestClass with call matcher, 5 at most 1 time, \(got)"
        failsWithErrorMessage(toExpectedMessage1) { toFailingTest1() }

        let toExpectedMessage2 = "expected to call <doStuffWith(string:)> from TestClass with swift at most 2 times, \(got)"
        failsWithErrorMessage(toExpectedMessage2) { toFailingTest2() }

        let toNotExpectedMessage = "expected to not call <doStuffWith(string:)> from TestClass with swift at most 4 times, \(got)"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to call function with arguments at most count times, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }
}
