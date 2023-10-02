import Foundation
import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class ContainElementSatisfyingTest: XCTestCase {
    // MARK: - Matcher variant
    func testContainElementSatisfying() {
        var orderIndifferentArray = [1, 2, 3]
        expect(orderIndifferentArray).to(containElementSatisfying({ number in
            return number == 1
        }))
        expect(orderIndifferentArray).to(containElementSatisfying({ number in
            return number == 2
        }))
        expect(orderIndifferentArray).to(containElementSatisfying({ number in
            return number == 3
        }))

        orderIndifferentArray = [3, 1, 2]
        expect(orderIndifferentArray).to(containElementSatisfying({ number in
            return number == 1
        }))
        expect(orderIndifferentArray).to(containElementSatisfying({ number in
            return number == 2
        }))
        expect(orderIndifferentArray).to(containElementSatisfying({ number in
            return number == 3
        }))
    }

    func testContainElementSatisfyingDefaultErrorMessage() {
        let orderIndifferentArray = [1, 2, 3]
        failsWithErrorMessage("expected to find object in collection that satisfies matcher") {
            expect(orderIndifferentArray).to(containElementSatisfying({ number in
                return number == 4
            }))
        }
    }

    func testContainElementSatisfyingSpecificErrorMessage() {
        let orderIndifferentArray = [1, 2, 3]
        failsWithErrorMessage("expected to find object in collection equal to 4") {
            expect(orderIndifferentArray).to(containElementSatisfying({ number in
                return number == 4
            }, "equal to 4"))
        }
    }

    func testContainElementSatisfyingNegativeCase() {
        let orderIndifferentArray = ["puppies", "kittens", "turtles"]
        expect(orderIndifferentArray).toNot(containElementSatisfying({ string in
            return string == "armadillos"
        }))
    }

    func testContainElementSatisfyingNegativeCaseDefaultErrorMessage() {
        let orderIndifferentArray = ["puppies", "kittens", "turtles"]
        failsWithErrorMessage("expected to not find object in collection that satisfies matcher") {
            expect(orderIndifferentArray).toNot(containElementSatisfying({ string in
                return string == "kittens"
            }))
        }
    }

    func testContainElementSatisfyingNegativeCaseSpecificErrorMessage() {
        let orderIndifferentArray = ["puppies", "kittens", "turtles"]
        failsWithErrorMessage("expected to not find object in collection equal to 'kittens'") {
            expect(orderIndifferentArray).toNot(containElementSatisfying({ string in
                return string == "kittens"
            }, "equal to 'kittens'"))
        }
    }

    // MARK: - AsyncMatcher variant
    func testAsyncContainElementSatisfying() async {
        var orderIndifferentArray = [1, 2, 3]
        await expect(orderIndifferentArray).to(containElementSatisfying({ number in
            await asyncEqualityCheck(number, 1)
        }))
        await expect(orderIndifferentArray).to(containElementSatisfying({ number in
            await asyncEqualityCheck(number, 2)
        }))
        await expect(orderIndifferentArray).to(containElementSatisfying({ number in
            await asyncEqualityCheck(number, 3)
        }))

        orderIndifferentArray = [3, 1, 2]
        await expect(orderIndifferentArray).to(containElementSatisfying({ number in
            await asyncEqualityCheck(number, 1)
        }))
        await expect(orderIndifferentArray).to(containElementSatisfying({ number in
            await asyncEqualityCheck(number, 2)
        }))
        await expect(orderIndifferentArray).to(containElementSatisfying({ number in
            await asyncEqualityCheck(number, 3)
        }))
    }

    func testAsyncContainElementSatisfyingDefaultErrorMessage() async {
        let orderIndifferentArray = [1, 2, 3]
        await failsWithErrorMessage("expected to find object in collection that satisfies matcher") {
            await expect(orderIndifferentArray).to(containElementSatisfying({ number in
                await asyncEqualityCheck(number, 4)
            }))
        }
    }

    func testAsyncContainElementSatisfyingSpecificErrorMessage() async {
        let orderIndifferentArray = [1, 2, 3]
        await failsWithErrorMessage("expected to find object in collection equal to 4") {
            await expect(orderIndifferentArray).to(containElementSatisfying({ number in
                await asyncEqualityCheck(number, 4)
            }, "equal to 4"))
        }
    }

    func testAsyncContainElementSatisfyingNegativeCase() async {
        let orderIndifferentArray = ["puppies", "kittens", "turtles"]
        await expect(orderIndifferentArray).toNot(containElementSatisfying({ string in
            await asyncEqualityCheck(string, "armadillos")
        }))
    }

    func testAsyncContainElementSatisfyingNegativeCaseDefaultErrorMessage() async {
        let orderIndifferentArray = ["puppies", "kittens", "turtles"]
        await failsWithErrorMessage("expected to not find object in collection that satisfies matcher") {
            await expect(orderIndifferentArray).toNot(containElementSatisfying({ string in
                await asyncEqualityCheck(string, "kittens")
            }))
        }
    }

    func testAsyncContainElementSatisfyingNegativeCaseSpecificErrorMessage() async {
        let orderIndifferentArray = ["puppies", "kittens", "turtles"]
        await failsWithErrorMessage("expected to not find object in collection equal to 'kittens'") {
            await expect(orderIndifferentArray).toNot(containElementSatisfying({ string in
                await asyncEqualityCheck(string, "kittens")
            }, "equal to 'kittens'"))
        }
    }
}
