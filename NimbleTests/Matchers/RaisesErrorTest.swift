import XCTest
import Nimble

class RaisesErrorTest: XCTestCase {
    let errorToThrow = NSError(domain: "foo", code: 2, userInfo: nil)

    private func doThrowError() throws {
        throw errorToThrow
    }

    private func doNotThrowError() throws {
    }

    func testPositiveMatches() {
        expect(try self.doThrowError()).to(throwAnError())
        expect(try self.doNotThrowError()).toNot(throwAnError())
        expect { try self.doThrowError() }.to(throwAnError())
        expect { try self.doNotThrowError() }.toNot(throwAnError())

        expect { try self.doThrowError() }.to(throwAnError { error in
            expect(error as NSError).to(equal(self.errorToThrow))
        })

        expect { try self.doThrowError() }.to(throwAnError { error in
            expect(error as NSError).to(equal(self.errorToThrow))
        })
    }

    func testNegativeMatches() {
        // does not compile: rdar:///21677942
        /*
        failsWithErrorMessage("expected to throw an error") {
            expect(try self.doNotThrowError()).to(throwAnError())
        }

        failsWithErrorMessage("expected to not throw an error, got <\(errorToThrow)>") {
            expect(try self.doThrowError()).toNot(throwAnError())
        }
        */

        failsWithErrorMessage("expected to throw an error") {
            expect { try self.doNotThrowError() }.to(throwAnError())
        }

        failsWithErrorMessage("expected to not throw an error, got <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toNot(throwAnError())
        }

        failsWithErrorMessage("expected to throw an error that satisfies block, got <\(errorToThrow)>") {
            expect { try self.doThrowError() }.to(throwAnError { error in
                expect(error as NSError?).to(beNil())
            })
        }

        failsWithErrorMessage("expected to not throw an error that satisfies block, got <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toNot(throwAnError { error in
                expect((error as NSError).domain).to(equal("LOL"))
            })
        }
    }

    func testSurprisingNegativeMatches() {
        // A tradeoff was made here to keep this failing instead possibly a more
        // intuitive passing expectation because:
        //
        // - Negative assertions are generally a poor testing pattern we should
        //   discourage. It's better to convert this to either an expectation
        //   that takes no block or one that throws with an expectation checking
        //   a known property of the error thrown.
        // - Making this pass will currently prevent the throwAnError closure's
        //   inner expectation failures from emiting proper line outputs. While
        //   anything is possible with more code, it's more complexity for
        //   little benefit (see first point).
        // - The expectation is confusing to interperate.
        //
        failsWithErrorMessage("expected to not throw an error that satisfies block, got <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toNot(throwAnError { error in
                expect(error as NSError?).to(beNil())
                })
        }
    }
}
