import XCTest
import Nimble

final class ToSucceedTest: XCTestCase {
    func testToSucceed() {
        expect {
            let result: Result<Bool, Error> = .success(true)
            
            switch result {
            case .success:
                return { .succeeded }
            default:
                return { .failed(reason: "") }
            }
        }.to(succeed())
                
        expect {
            .succeeded
        }.to(succeed())

        expect {
            .failed(reason: "")
        } .toNot(succeed())

        failsWithErrorMessageForNil("expected a closure, got <nil>") {
            expect(nil as (() -> ToSucceedResult)?).to(succeed())
        }

        failsWithErrorMessage("expected to succeed, got <failed> because <something went wrong>") {
            expect {
                .failed(reason: "something went wrong")
            } .to(succeed())
        }

        failsWithErrorMessage("expected to not succeed, got <succeeded>") {
            expect {
                .succeeded
            } .toNot(succeed())
        }
    }
}
