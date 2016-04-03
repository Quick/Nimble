import Foundation
import XCTest
import Nimble

class MatchErrorTest: XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testMatchErrorPositive", testMatchErrorPositive),
            ("testMatchErrorNegative", testMatchErrorNegative),
            ("testMatchNSErrorPositive", testMatchNSErrorPositive),
            ("testMatchNSErrorNegative", testMatchNSErrorNegative),
            ("testMatchPositiveMessage", testMatchPositiveMessage),
            ("testMatchNegativeMessage", testMatchNegativeMessage),
            ("testDoesNotMatchNils", testDoesNotMatchNils),
        ]
    }

    func testMatchErrorPositive() {
        expect(Error.Laugh).to(matchError(Error.Laugh))
        expect(Error.Laugh).to(matchError(Error.self))
        expect(EquatableError.Parameterized(x: 1)).to(matchError(EquatableError.Parameterized(x: 1)))

        expect(Error.Laugh as ErrorType).to(matchError(Error.Laugh))
    }

    func testMatchErrorNegative() {
        expect(Error.Laugh).toNot(matchError(Error.Cry))
        expect(Error.Laugh as ErrorType).toNot(matchError(Error.Cry))
    }

    func testMatchNSErrorPositive() {
        let error1 = NSError(domain: "err", code: 0, userInfo: nil)
        let error2 = NSError(domain: "err", code: 0, userInfo: nil)

        expect(error1).to(matchError(error2))
    }

    func testMatchNSErrorNegative() {
        let error1 = NSError(domain: "err", code: 0, userInfo: nil)
        let error2 = NSError(domain: "err", code: 1, userInfo: nil)

        expect(error1).toNot(matchError(error2))
    }

    func testMatchPositiveMessage() {
        failsWithErrorMessage("expected to match error <Parameterized(2)>, got <Parameterized(1)>") {
            expect(EquatableError.Parameterized(x: 1)).to(matchError(EquatableError.Parameterized(x: 2)))
        }
        failsWithErrorMessage("expected to match error <Cry>, got <Laugh>") {
            expect(Error.Laugh).to(matchError(Error.Cry))
        }
        failsWithErrorMessage("expected to match error <code=1>, got <code=0>") {
            expect(CustomDebugStringConvertibleError.A).to(matchError(CustomDebugStringConvertibleError.B))
        }

        failsWithErrorMessage("expected to match error <Error Domain=err Code=1 \"(null)\">, got <Error Domain=err Code=0 \"(null)\">") {
            let error1 = NSError(domain: "err", code: 0, userInfo: nil)
            let error2 = NSError(domain: "err", code: 1, userInfo: nil)
            expect(error1).to(matchError(error2))
        }
    }

    func testMatchNegativeMessage() {
        failsWithErrorMessage("expected to not match error <Laugh>, got <Laugh>") {
            expect(Error.Laugh).toNot(matchError(Error.Laugh))
        }
    }

    func testDoesNotMatchNils() {
        failsWithErrorMessageForNil("expected to match error <Laugh>, got no error") {
            expect(nil as ErrorType?).to(matchError(Error.Laugh))
        }

        failsWithErrorMessageForNil("expected to not match error <Laugh>, got no error") {
            expect(nil as ErrorType?).toNot(matchError(Error.Laugh))
        }
    }
}
