import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

final class MapTest: XCTestCase {
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
        func someOperation(_ value: Int) async -> String {
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
            map(\.int, equal(3)),
            map(\.string, equal("world"))
        ))
    }
}
