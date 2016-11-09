import Foundation
import XCTest
import Nimble

final class ContainObjectSatisfyingTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (ContainObjectSatisfyingTest) -> () throws -> Void)] {
        return [
            ("testContainObjectSatisfying", testContainObjectSatisfying),
            ("testContainObjectSatisfyingDefaultErrorMessage", testContainObjectSatisfyingDefaultErrorMessage),
            ("testContainObjectSatisfyingSpecificErrorMessage", testContainObjectSatisfyingSpecificErrorMessage),
            ("testContainObjectSatisfyingNegativeCase",
             testContainObjectSatisfyingNegativeCase),
            ("testContainObjectSatisfyingNegativeCaseDefaultErrorMessage",
             testContainObjectSatisfyingNegativeCaseDefaultErrorMessage),
            ("testContainObjectSatisfyingNegativeCaseSpecificErrorMessage",
             testContainObjectSatisfyingNegativeCaseSpecificErrorMessage)
        ]
    }

    func testContainObjectSatisfying() {
        var orderIndifferentArray = [1,2,3]
        expect(orderIndifferentArray).to(containObjectSatisfying({ number in
            return number == 1
        }))
        expect(orderIndifferentArray).to(containObjectSatisfying({ number in
            return number == 2
        }))
        expect(orderIndifferentArray).to(containObjectSatisfying({ number in
            return number == 3
        }))

        orderIndifferentArray = [3,1,2]
        expect(orderIndifferentArray).to(containObjectSatisfying({ number in
            return number == 1
        }))
        expect(orderIndifferentArray).to(containObjectSatisfying({ number in
            return number == 2
        }))
        expect(orderIndifferentArray).to(containObjectSatisfying({ number in
            return number == 3
        }))
    }

    func testContainObjectSatisfyingDefaultErrorMessage() {
        let orderIndifferentArray = [1,2,3]
        failsWithErrorMessage("expected to find object in collection that satisfies predicate") {
            expect(orderIndifferentArray).to(containObjectSatisfying({ number in
                return number == 4
            }))
        }
    }

    func testContainObjectSatisfyingSpecificErrorMessage() {
        let orderIndifferentArray = [1,2,3]
        failsWithErrorMessage("expected to find object in collection equal to 4") {
            expect(orderIndifferentArray).to(containObjectSatisfying({ number in
                return number == 4
            }, "equal to 4"))
        }
    }

    func testContainObjectSatisfyingNegativeCase() {
        let orderIndifferentArray = ["puppies", "kittens", "turtles"]
        expect(orderIndifferentArray).toNot(containObjectSatisfying({ string in
            return string == "armadillos"
        }))
    }

    func testContainObjectSatisfyingNegativeCaseDefaultErrorMessage() {
        let orderIndifferentArray = ["puppies", "kittens", "turtles"]
        failsWithErrorMessage("expected to not find object in collection that satisfies predicate") {
            expect(orderIndifferentArray).toNot(containObjectSatisfying({ string in
                return string == "kittens"
            }))
        }
    }

    func testContainObjectSatisfyingNegativeCaseSpecificErrorMessage() {
        let orderIndifferentArray = ["puppies", "kittens", "turtles"]
        failsWithErrorMessage("expected to not find object in collection equal to 'kittens'") {
            expect(orderIndifferentArray).toNot(containObjectSatisfying({ string in
                return string == "kittens"
            }, "equal to 'kittens'"))
        }
    }
}
