import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class ToSucceedTest: XCTestCase {
    func testToSucceed() {
        expect {
            return .succeeded
        }.to(succeed())

        expect {
            return .failed(reason: "")
        }.toNot(succeed())

        expect {
            let result = ToSucceedResult.succeeded
            return result
        }.to(succeed())

        failsWithErrorMessageForNil("expected a ToSucceedResult, got <nil>") {
            expect(nil).to(succeed())
        }

        failsWithErrorMessage("expected to succeed, got <failed> because <something went wrong>") {
            expect {
                .failed(reason: "something went wrong")
            }.to(succeed())
        }

        failsWithErrorMessage("expected to not succeed, got <succeeded>") {
            expect {
                return .succeeded
            }.toNot(succeed())
        }
    }
}
