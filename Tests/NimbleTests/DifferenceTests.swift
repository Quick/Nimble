//
//  DifferenceTests.swift
//  Difference
//
//  Created by Krzysztof Zablocki on 18.10.2017
//  Copyright © 2017 Krzysztof Zablocki. All rights reserved.
//

import Foundation
import XCTest
import Difference

typealias IndentationType = Difference.IndentationType

fileprivate struct Person: Equatable {
    let name: String
    let age: Int
    let address: Address
    let pet: Pet?
    let petAges: [String: Int]?
    let favoriteFoods: Set<String>?

    init(
        name: String = "Krzysztof",
        age: Int = 29,
        address: Address = .init(),
        pet: Pet? = .init(),
        petAges: [String: Int]? = nil,
        favoriteFoods: Set<String>? = nil
    ) {
        self.name = name
        self.age = age
        self.address = address
        self.pet = pet
        self.petAges = petAges
        self.favoriteFoods = favoriteFoods
    }

    struct Address: Equatable {
        let street: String
        let postCode: String
        let counter: ComplexCounter

        init(
            street: String = "Times Square",
            postCode: String = "00-1000",
            counter: ComplexCounter = .init()
        ) {
            self.street = street
            self.postCode = postCode
            self.counter = counter
        }

        struct ComplexCounter: Equatable {
            let counter: Int

            init(counter: Int = 2) {
                self.counter = counter
            }
        }
    }

    struct Pet: Equatable {
        let name: String

        init(name: String = "Fluffy") {
            self.name = name
        }
    }
}

private enum State {
    case loaded([Int], String)
    case anotherLoaded([Int], String)
    case loadedWithDiffArguments(Int)
    case loadedWithNoArguments
}

extension String {
    func adjustingFor(indentationType: IndentationType) -> String {
        switch indentationType {
        case .pipe:
            return self
        case .tab:
            return self.replacingOccurrences(of: "|", with: "")
        }
    }
}

class DifferenceTests: XCTestCase {

    private func runTest<T>(
        expected: T,
        received: T,
        expectedResults: [String],
        skipPrintingOnDiffCount: Bool = false
    ) {
        IndentationType.allCases.forEach { indentationType in
            let results = diff(expected, received, indentationType: indentationType, skipPrintingOnDiffCount: skipPrintingOnDiffCount)
            let preppedExpected = expectedResults.map { $0.adjustingFor(indentationType: indentationType) }
            XCTAssertEqual(results.count, expectedResults.count)
            XCTAssertEqual(results, preppedExpected)
        }
    }

    func testCanFindRootPrimitiveDifference() {
        runTest(
            expected: 2,
            received: 3,
            expectedResults: ["Received: 3\nExpected: 2\n"]
        )
    }

    fileprivate let truth = Person()

    func testCanFindPrimitiveDifference() {
        runTest(
            expected: truth,
            received: Person(age: 30),
            expectedResults: ["age:\n|\tReceived: 30\n|\tExpected: 29\n"]
        )
    }

    func testCanFindMultipleDifference() {
        runTest(
            expected: truth,
            received: Person(name: "Adam", age: 30),
            expectedResults: [
                "name:\n|\tReceived: Adam\n|\tExpected: Krzysztof\n",
                "age:\n|\tReceived: 30\n|\tExpected: 29\n"
            ]
        )
    }

    func testCanFindComplexDifference() {
        runTest(
            expected: truth,
            received: Person(address: Person.Address(street: "2nd Street", counter: .init(counter: 1))),
            expectedResults: ["address:\n|\tcounter:\n|\t|\tcounter:\n|\t|\t|\tReceived: 1\n|\t|\t|\tExpected: 2\n|\tstreet:\n|\t|\tReceived: 2nd Street\n|\t|\tExpected: Times Square\n"]
        )
    }

    func testCanGiveDescriptionForOptionalOnLeftSide() {
        let results = diff(Person(pet: nil), Person())
        XCTAssertEqual(results.count, 1)
    }

    func testCanGiveDescriptionForOptionalOnRightSide() {
        let results = diff(Person(), Person(pet: nil))
        XCTAssertEqual(results.count, 1)
    }

    // MARK: Collections

    func test_canFindCollectionCountDifference() {
        runTest(
            expected: [1],
            received: [1, 3],
            expectedResults: ["Different count:\n|\tReceived: (2) [1, 3]\n|\tExpected: (1) [1]\n"]
        )
    }

    func test_canFindCollectionCountDifference_complex() {
        runTest(
            expected: State.loaded([1, 2], "truthString"),
            received: State.loaded([], "stubString"),
            expectedResults: ["Enum loaded:\n|\t.0:\n|\t|\tDifferent count:\n|\t|\t|\tReceived: (0) []\n|\t|\t|\tExpected: (2) [1, 2]\n|\t.1:\n|\t|\tReceived: stubString\n|\t|\tExpected: truthString\n"]
        )
    }

    func test_collectionCountDifference_withoutPrintingObject() {
        dumpDiff([1], [1, 3], indentationType: .pipe, skipPrintingOnDiffCount: true)
        runTest(
            expected: [1],
            received: [1, 3],
            expectedResults: ["Different count:\n|\tReceived: (2)\n|\tExpected: (1)\n"],
            skipPrintingOnDiffCount: true
        )
    }

    func test_labelsArrayElementsInDiff() {
        runTest(
            expected: [Person(), Person(name: "John")],
            received: [Person(name: "John"), Person()],
            expectedResults: [
                "Collection[0]:\n|\tname:\n|\t|\tReceived: John\n|\t|\tExpected: Krzysztof\n",
                "Collection[1]:\n|\tname:\n|\t|\tReceived: Krzysztof\n|\t|\tExpected: John\n"
            ]
        )
    }

    // MARK: Enums

    func test_canFindEnumCaseDifferenceWhenAssociatedValuesAreIdentical() {
        runTest(
            expected: State.loaded([0], "CommonString"),
            received: State.anotherLoaded([0], "CommonString"),
            expectedResults: ["Received: anotherLoaded\nExpected: loaded\n"]
        )
    }

    func test_canFindEnumCaseDifferenceWhenLessArguments() {
        runTest(
            expected: State.loaded([0], "CommonString"),
            received: State.loadedWithDiffArguments(1),
            expectedResults: ["Received: loadedWithDiffArguments\nExpected: loaded\n"]
        )
    }

    // MARK: Dictionaries

    func test_canFindDictionaryCountDifference() {
        runTest(
            expected: Person(petAges: ["Henny": 4]),
            received: Person(petAges: [:]),
            expectedResults: ["petAges:\n|\tDifferent count:\n|\t|\tReceived: (0) [:]\n|\t|\tExpected: (1) [\"Henny\": 4]\n"]
        )
    }

    func test_canFindOptionalDifferenceBetweenSomeAndNone() {
        runTest(
            expected: Person(petAges: ["Henny": 4]),
            received: Person(petAges: nil),
            expectedResults: ["petAges:\n|\tReceived: nil\n|\tExpected: Optional([\"Henny\": 4])\n"]
        )
    }

    func test_canFindDictionaryDifference() {
        runTest(
            expected: Person(petAges: ["Henny": 4, "Jethro": 6]),
            received: Person(petAges: ["Henny": 1, "Jethro": 2]),
            expectedResults: ["petAges:\n|\tKey Henny:\n|\t|\tReceived: 1\n|\t|\tExpected: 4\n|\tKey Jethro:\n|\t|\tReceived: 2\n|\t|\tExpected: 6\n"]
        )
    }

    // MARK: Sets

    func test_canFindSetCountDifference() {
        runTest(
            expected: Person(favoriteFoods: []),
            received: Person(favoriteFoods: ["Oysters"]),
            expectedResults: ["favoriteFoods:\n|\tDifferent count:\n|\t|\tReceived: (1) [\"Oysters\"]\n|\t|\tExpected: (0) []\n"]
        )
    }

    func test_canFindOptionalSetDifferenceBetweenSomeAndNone() {
        runTest(
            expected: Person(favoriteFoods: ["Oysters"]),
            received: Person(favoriteFoods: nil),
            expectedResults: ["favoriteFoods:\n|\tReceived: nil\n|\tExpected: Optional(Set([\"Oysters\"]))\n"]
        )
    }

    func test_canFindSetDifference() {
        runTest(
            expected: Person(favoriteFoods: ["Sushi", "Pizza"]),
            received: Person(favoriteFoods: ["Oysters", "Crab"]),
            expectedResults: ["favoriteFoods:\n|\tMissing: Pizza\n|\tMissing: Sushi\n"]
        )
    }
}

extension DifferenceTests {
    static var allTests = [
        ("testCanFindRootPrimitiveDifference", testCanFindRootPrimitiveDifference),
        ("testCanFindPrimitiveDifference", testCanFindPrimitiveDifference),
        ("testCanFindMultipleDifference", testCanFindMultipleDifference),
        ("testCanFindComplexDifference", testCanFindComplexDifference),
        ("testCanGiveDescriptionForOptionalOnLeftSide", testCanGiveDescriptionForOptionalOnLeftSide),
        ("testCanGiveDescriptionForOptionalOnRightSide", testCanGiveDescriptionForOptionalOnRightSide),
        ("test_canFindCollectionCountDifference", test_canFindCollectionCountDifference),
        ("test_canFindCollectionCountDifference_complex", test_canFindCollectionCountDifference_complex),
        ("test_labelsArrayElementsInDiff", test_labelsArrayElementsInDiff),
        ("test_canFindEnumCaseDifferenceWhenAssociatedValuesAreIdentical", test_canFindEnumCaseDifferenceWhenAssociatedValuesAreIdentical),
        ("test_canFindEnumCaseDifferenceWhenLessArguments", test_canFindEnumCaseDifferenceWhenLessArguments),
        ("test_canFindDictionaryCountDifference", test_canFindDictionaryCountDifference),
        ("test_canFindOptionalDifferenceBetweenSomeAndNone", test_canFindOptionalDifferenceBetweenSomeAndNone),
        ("test_canFindDictionaryDifference", test_canFindDictionaryDifference),
        ("test_canFindSetCountDifference", test_canFindSetCountDifference),
        ("test_canFindOptionalSetDifferenceBetweenSomeAndNone", test_canFindOptionalSetDifferenceBetweenSomeAndNone),
        ("test_canFindSetDifference", test_canFindSetDifference)
    ]
}
