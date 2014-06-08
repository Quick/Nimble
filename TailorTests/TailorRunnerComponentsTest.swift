import XCTest
import Tailor

class TailorBootstrap : TSSpec {
    override func defineBehaviors() {
        describe("closure execution") {
            it("should call beforeEachs, then then the it, followed by afterEachs") {
                var callHistory = String[]()

                var spec = TSSpecContext.behaviors {
                    beforeEach { callHistory.append("beforeEach1") }
                    afterEach { callHistory.append("afterEach1") }
                    beforeEach { callHistory.append("beforeEach2") }
                    afterEach { callHistory.append("afterEach2") }

                    describe("Cake") {
                        beforeEach { callHistory.append("beforeEach3") }
                        afterEach { callHistory.append("afterEach3") }
                        it("is yummy") {
                            callHistory.append("it")
                        }
                    }
                }
                spec.verifyBehaviors()

                let expectedCallOrder = [
                    "beforeEach1",
                    "beforeEach2",
                    "beforeEach3",
                    "it",
                    "afterEach3",
                    "afterEach2",
                    "afterEach1",
                ]
                expect(callHistory).to(equalTo(expectedCallOrder))
            }

            it("call nested blocks immediately") {
                var describeWasCalled = false
                var contextWasCalled = false
                var nestedWasCalled = false
                var leafWasCalled = false

                TSSpecContext.behaviors {
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
        }

        context("when inside a beforeEach") {
            it("should throw errors") {
                let spec = TSSpecContext.behaviors {
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
        }
    }
}
