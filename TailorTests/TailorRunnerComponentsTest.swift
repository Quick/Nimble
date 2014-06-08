import XCTest
import Tailor

class TailorBootstrap : TSSpec {
    override func spec() -> SpecBehavior! {
        return behaviors {
            describe("cheese") {
                it("should be brown") {
                    expect(1).to(equalTo(1))
                }
            }
        }
    }

    func testRunsLeavesOnVerification() {
        var callHistory = String[]()
        var spec = behaviors {
            beforeEach { callHistory.append("beforeEach1") }
            afterEach { callHistory.append("afterEach1") }

            describe("Cake") {
                beforeEach { callHistory.append("beforeEach2") }
                afterEach { callHistory.append("afterEach2") }
                it("is yummy") {
                    callHistory.append("it")
                }
            }
        }
        spec.verifyBehaviors()

        let expectedCallOrder = [
            "beforeEach1",
            "beforeEach2",
            "it",
            "afterEach2",
            "afterEach1",
        ]
        expect(callHistory).to(equalTo(expectedCallOrder))
    }

    func testRunsNestingBlocksImmediately() {
        var describeWasCalled = false
        var contextWasCalled = false
        var nestedWasCalled = false
        var leafWasCalled = false

        behaviors {
            beforeEach { leafWasCalled = true }
            afterEach { leafWasCalled = true }
            it("should not invoke") { leafWasCalled = true }

            describe("stuff") {
                describeWasCalled = true

                beforeEach { leafWasCalled = true }
                afterEach { leafWasCalled = true }
                it("should not invoke") { leafWasCalled = true }

                context("sub context") {
                    nestedWasCalled = true

                    beforeEach { leafWasCalled = true }
                    afterEach { leafWasCalled = true }
                    it("should not invoke") { leafWasCalled = true }
                }
            }

            context("context") {
                contextWasCalled = true

                beforeEach { leafWasCalled = true }
                afterEach { leafWasCalled = true }
                it("should not invoke") { leafWasCalled = true }
            }
        }
        expect(describeWasCalled).to(beTruthy())
        expect(contextWasCalled).to(beTruthy())
        expect(nestedWasCalled).to(beTruthy())
        expect(leafWasCalled).to(beFalsy())
    }

    func testDoNotAllowNestingInsideBeforeEachOrAfterEach() {
        var spec = behaviors {
            beforeEach {
                failsWithErrorMessage("describe() is not allowed here") {
                    describe("") {}
                }
                failsWithErrorMessage("context() is not allowed here") {
                    context("") {}
                }
                failsWithErrorMessage("it() is not allowed here") {
                    it("") {}
                }
            }
            afterEach {
                failsWithErrorMessage("describe() is not allowed here") {
                    describe("") {}
                }
                failsWithErrorMessage("context() is not allowed here") {
                    context("") {}
                }
                failsWithErrorMessage("it() is not allowed here") {
                    it("") {}
                }
            }
        }
        spec.verifyBehaviors()
    }

    func testDoNotAllowDSLIsolatedFromBehaviors() {
        failsWithErrorMessage("beforeEach() is not allowed here") {
            beforeEach {}
        }
        failsWithErrorMessage("afterEach() is not allowed here") {
            afterEach {}
        }
        failsWithErrorMessage("describe() is not allowed here") {
            describe("Food") {}
        }
        failsWithErrorMessage("context() is not allowed here") {
            context("Kitchen") {}
        }
        failsWithErrorMessage("it() is not allowed here") {
            it("eats") {}
        }
    }
}
