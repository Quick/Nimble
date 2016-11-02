import Foundation
import XCTest
@testable import Nimble

final class ContainObjectSatisfyingTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (ContainObjectSatisfyingTest) -> () throws -> Void)] {
        return [
            ("testContainObjectSatisfying", testContainObjectSatisfying),
            ("testContainObjectSatisfyingDefaultErrorMessage", testContainObjectSatisfyingDefaultErrorMessage),
            ("testContainObjectSatisfyingSpecificErrorMessage", testContainObjectSatisfyingSpecificErrorMessage)
        ]
    }

    func testContainObjectSatisfying() {
        var orderIndifferentArray = [1,2,3]
        expect(orderIndifferentArray).to(containObjectSatisfying({ number in
            number == 1
        }))
        expect(orderIndifferentArray).to(containObjectSatisfying({ number in
            number == 2
        }))
        expect(orderIndifferentArray).to(containObjectSatisfying({ number in
            number == 3
        }))

        orderIndifferentArray = [3,1,2]
        expect(orderIndifferentArray).to(containObjectSatisfying({ number in
            number == 1
        }))
        expect(orderIndifferentArray).to(containObjectSatisfying({ number in
            number == 2
        }))
        expect(orderIndifferentArray).to(containObjectSatisfying({ number in
            number == 3
        }))
    }

    func testContainObjectSatisfyingDefaultErrorMessage() {
        let orderIndifferentArray = [1,2,3]
        failsWithErrorMessage("expected to find object in collection that satisfies predicate") {
            expect(orderIndifferentArray).to(containObjectSatisfying({ number in
                number == 4
            }))
        }
    }

    func testContainObjectSatisfyingSpecificErrorMessage() {
        let orderIndifferentArray = [1,2,3]
        failsWithErrorMessage("expected to find object in collection equal to 4") {
            expect(orderIndifferentArray).to(containObjectSatisfying({ number in
                number == 4
            }, "equal to 4"))
        }
    }
}
