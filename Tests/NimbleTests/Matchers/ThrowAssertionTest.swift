import Foundation
import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

private let error: Error = NSError(domain: "test", code: 0, userInfo: nil)

final class ThrowAssertionTest: XCTestCase {
    func testPositiveMatch() {
        #if (arch(x86_64) || arch(arm64)) && !os(Windows)
        expect { () -> Void in fatalError() }.to(throwAssertion())
        #endif
    }

    func testErrorThrown() {
        #if (arch(x86_64) || arch(arm64)) && !os(Windows)
        expect { throw error }.toNot(throwAssertion())
        #endif
    }

    func testPostAssertionCodeNotRun() {
        #if (arch(x86_64) || arch(arm64)) && !os(Windows)
        var reachedPoint1 = false
        var reachedPoint2 = false

        expect {
            reachedPoint1 = true
            precondition(false, "condition message")
            reachedPoint2 = true
        }.to(throwAssertion())

        expect(reachedPoint1) == true
        expect(reachedPoint2) == false
        #endif
    }

    func testNegativeMatch() {
        #if (arch(x86_64) || arch(arm64)) && !os(Windows)
        var reachedPoint1 = false

        expect { reachedPoint1 = true }.toNot(throwAssertion())

        expect(reachedPoint1) == true
        #endif
    }

    func testPositiveMessage() {
        #if (arch(x86_64) || arch(arm64)) && !os(Windows)
        failsWithErrorMessage("expected to throw an assertion") {
            expect { () -> Void? in return }.to(throwAssertion())
        }

        failsWithErrorMessage("expected to throw an assertion; threw error instead <\(error)>") {
            expect { throw error }.to(throwAssertion())
        }
        #endif
    }

    func testNegativeMessage() {
        #if (arch(x86_64) || arch(arm64)) && !os(Windows)
        failsWithErrorMessage("expected to not throw an assertion") {
            expect { () -> Void in fatalError() }.toNot(throwAssertion())
        }
        #endif
    }

    func testNonVoidClosure() {
        #if (arch(x86_64) || arch(arm64)) && !os(Windows)
        expect { () -> Int in fatalError() }.to(throwAssertion())
        #endif
    }

    func testChainOnThrowAssertion() {
        #if (arch(x86_64) || arch(arm64)) && !os(Windows)
        expect { () -> Int in return 5 }.toNot(throwAssertion()).to(equal(5))
        #endif
    }
}
