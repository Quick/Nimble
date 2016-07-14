import Foundation
import XCTest
import Nimble

final class MatchErrorTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (MatchErrorTest) -> () throws -> Void)] {
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
        expect(Error.laugh).to(matchError(Error.laugh))
        expect(Error.laugh).to(matchError(Error.self))
        expect(EquatableError.parameterized(x: 1)).to(matchError(EquatableError.parameterized(x: 1)))

        expect(Error.laugh as ErrorProtocol).to(matchError(Error.laugh))
    }

    func testMatchErrorNegative() {
        expect(Error.laugh).toNot(matchError(Error.cry))
        expect(Error.laugh as ErrorProtocol).toNot(matchError(Error.cry))
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
        failsWithErrorMessage("expected to match error <parameterized(2)>, got <parameterized(1)>") {
            expect(EquatableError.parameterized(x: 1)).to(matchError(EquatableError.parameterized(x: 2)))
        }
        failsWithErrorMessage("expected to match error <cry>, got <laugh>") {
            expect(Error.laugh).to(matchError(Error.cry))
        }
        failsWithErrorMessage("expected to match error <code=1>, got <code=0>") {
            expect(CustomDebugStringConvertibleError.a).to(matchError(CustomDebugStringConvertibleError.b))
        }

        failsWithErrorMessage("expected to match error <Error Domain=err Code=1 \"(null)\">, got <Error Domain=err Code=0 \"(null)\">") {
            let error1 = NSError(domain: "err", code: 0, userInfo: nil)
            let error2 = NSError(domain: "err", code: 1, userInfo: nil)
            expect(error1).to(matchError(error2))
        }
    }

    func testMatchNegativeMessage() {
        failsWithErrorMessage("expected to not match error <laugh>, got <laugh>") {
            expect(Error.laugh).toNot(matchError(Error.laugh))
        }
    }

    func testDoesNotMatchNils() {
        failsWithErrorMessageForNil("expected to match error <laugh>, got no error") {
            expect(nil as ErrorProtocol?).to(matchError(Error.laugh))
        }

        failsWithErrorMessageForNil("expected to not match error <laugh>, got no error") {
            expect(nil as ErrorProtocol?).toNot(matchError(Error.laugh))
        }
    }
}
