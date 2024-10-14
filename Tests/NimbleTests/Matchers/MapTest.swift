import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class MapTest: XCTestCase {
    // MARK: Map
    func testMap() {
        expect(1).to(map({ $0 }, equal(1)))

        struct Value {
            let int: Int
            let string: String?
        }

        expect(Value(
            int: 1,
            string: "hello"
        )).to(satisfyAllOf(
            map(\.int, equal(1)),
            map(\.string, equal("hello"))
        ))

        expect(Value(
            int: 1,
            string: "hello"
        )).to(satisfyAnyOf(
            map(\.int, equal(2)),
            map(\.string, equal("hello"))
        ))

        expect(Value(
            int: 1,
            string: "hello"
        )).toNot(satisfyAllOf(
            map(\.int, equal(2)),
            map(\.string, equal("hello"))
        ))
    }

    func testMapAsync() async {
        struct Value {
            let int: Int
            let string: String
        }

        await expect(Value(
            int: 1,
            string: "hello"
        )).to(map(\.int, asyncEqual(1)))

        await expect(Value(
            int: 1,
            string: "hello"
        )).toNot(map(\.int, asyncEqual(2)))
    }

    func testMapWithAsyncFunction() async {
        @Sendable func someOperation(_ value: Int) async -> String {
            "\(value)"
        }
        await expect(1).to(map(someOperation, equal("1")))
    }

    func testMapWithActor() {
        actor Box {
            let int: Int
            let string: String

            init(int: Int, string: String) {
                self.int = int
                self.string = string
            }
        }

        let box = Box(int: 3, string: "world")

        expect(box).to(satisfyAllOf(
            map( { $0.int }, equal(3)),
            map( { $0.string }, equal("world"))
        ))
    }

    // MARK: Failable map
    func testFailableMap() {
        expect("1").to(map({ Int($0) }, equal(1)))

        struct Value {
            let int: Int?
            let string: String?
        }

        expect(Value(
            int: 1,
            string: "hello"
        )).to(satisfyAllOf(
            map(\.int, equal(1)),
            map(\.string, equal("hello"))
        ))

        expect(Value(
            int: 1,
            string: "hello"
        )).to(satisfyAnyOf(
            map(\.int, equal(2)),
            map(\.string, equal("hello"))
        ))

        expect(Value(
            int: 1,
            string: "hello"
        )).toNot(satisfyAllOf(
            map(\.int, equal(2)),
            map(\.string, equal("hello"))
        ))
    }

    func testFailableMapAsync() async {
        struct Value {
            let int: Int?
            let string: String?
        }

        await expect(Value(
            int: 1,
            string: "hello"
        )).to(map(\.int, asyncEqual(1)))

        await expect(Value(
            int: 1,
            string: "hello"
        )).toNot(map(\.int, asyncEqual(2)))
    }

    func testFailableMapWithAsyncFunction() async {
        func someOperation(_ value: Int) async -> String? {
            "\(value)"
        }
        await expect(1).to(map(someOperation, equal("1")))
    }

    func testFailableMapWithActor() {
        actor Box {
            let int: Int?
            let string: String?

            init(int: Int, string: String) {
                self.int = int
                self.string = string
            }
        }

        let box = Box(int: 3, string: "world")

        expect(box).to(satisfyAllOf(
            map(\.int, equal(3)),
            map(\.string, equal("world"))
        ))
    }

    // MARK: Compact map
    func testCompactMap() {
        expect("1").to(compactMap({ Int($0) }, equal(1)))
        expect("1").toNot(compactMap({ Int($0) }, equal(2)))

        let assertions = gatherExpectations(silently: true) {
            expect("not a number").to(compactMap({ Int($0) }, equal(1)))
            expect("not a number").toNot(compactMap({ Int($0) }, equal(1)))
        }

        expect(assertions).to(haveCount(2))
        expect(assertions.first?.success).to(beFalse())
        expect(assertions.last?.success).to(beFalse())
    }

    func testCompactMapAsync() async {
        struct Value {
            let int: Int?
            let string: String?
        }

        await expect("1").to(compactMap({ Int($0) }, asyncEqual(1)))
        await expect("1").toNot(compactMap({ Int($0) }, asyncEqual(2)))

        let assertions = await gatherExpectations(silently: true) {
            await expect("not a number").to(compactMap({ Int($0) }, asyncEqual(1)))
            await expect("not a number").toNot(compactMap({ Int($0) }, asyncEqual(1)))
        }

        expect(assertions).to(haveCount(2))
        expect(assertions.first?.success).to(beFalse())
        expect(assertions.last?.success).to(beFalse())
    }

    func testCompactMapWithAsyncFunction() async {
        func someOperation(_ value: Int) async -> String? {
            "\(value)"
        }
        await expect(1).to(compactMap(someOperation, equal("1")))

        func someFailingOperation(_ value: Int) async -> String? {
            nil
        }

        let assertions = await gatherExpectations(silently: true) {
            await expect(1).to(compactMap(someFailingOperation, equal("1")))
            await expect(1).toNot(compactMap(someFailingOperation, equal("1")))
        }

        expect(assertions).to(haveCount(2))
        expect(assertions.first?.success).to(beFalse())
        expect(assertions.last?.success).to(beFalse())
    }

    func testCompactMapWithActor() {
        actor Box {
            let int: Int?
            let string: String?

            init(int: Int?, string: String?) {
                self.int = int
                self.string = string
            }
        }

        let box = Box(int: 3, string: "world")

        expect(box).to(satisfyAllOf(
            compactMap(\.int, equal(3)),
            compactMap(\.string, equal("world"))
        ))

        let failingBox = Box(int: nil, string: nil)

        let assertions = gatherExpectations(silently: true) {
            expect(failingBox).to(satisfyAllOf(
                compactMap(\.int, equal(3))
            ))
            expect(failingBox).toNot(satisfyAllOf(
                compactMap(\.int, equal(3))
            ))
        }
        expect(assertions).to(haveCount(2))
        expect(assertions.first?.success).to(beFalse())
        expect(assertions.last?.success).to(beFalse())
    }
}
