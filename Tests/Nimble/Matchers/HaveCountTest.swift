import XCTest
import Nimble

class HaveCountTest: XCTestCase, XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("testHaveCountForArray", testHaveCountForArray),
            ("testHaveCountForDictionary", testHaveCountForDictionary),
            ("testHaveCountForSet", testHaveCountForSet),
        ]
    }

    func testHaveCountForArray() {
        expect([1, 2, 3]).to(haveCount(3))
        expect([1, 2, 3]).notTo(haveCount(1))

        failsWithErrorMessage("expected to have [1, 2, 3] with count 1, got 3") {
            expect([1, 2, 3]).to(haveCount(1))
        }

        failsWithErrorMessage("expected to not have [1, 2, 3] with count 3, got 3") {
            expect([1, 2, 3]).notTo(haveCount(3))
        }
    }

    func testHaveCountForDictionary() {
        let dictionary = ["1":1, "2":2, "3":3]
        expect(dictionary).to(haveCount(3))
        expect(dictionary).notTo(haveCount(1))

        failsWithErrorMessage("expected to have \(stringify(dictionary)) with count 1, got 3") {
            expect(dictionary).to(haveCount(1))
        }

        failsWithErrorMessage("expected to not have \(stringify(dictionary)) with count 3, got 3") {
            expect(dictionary).notTo(haveCount(3))
        }
    }

    func testHaveCountForSet() {
        let set = Set([1, 2, 3])
        expect(set).to(haveCount(3))
        expect(set).notTo(haveCount(1))

        failsWithErrorMessage("expected to have \(stringify(set)) with count 1, got 3") {
            expect(set).to(haveCount(1))
        }

        failsWithErrorMessage("expected to not have \(stringify(set)) with count 3, got 3") {
            expect(set).notTo(haveCount(3))
        }
    }
}
