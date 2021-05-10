import Foundation
import XCTest
import Nimble

final class BeWithinTest: XCTestCase {
    func testBeWithinPositiveMatches() {
        // Range
        expect(0.1).to(beWithin(0.1..<1.1))
        expect(4).to(beWithin(3..<5))
        expect(-3).to(beWithin(-7..<5))

        expect(0.3).toNot(beWithin(0.31..<0.99))
        expect(2).toNot(beWithin(0..<2))
        expect(-7.1).toNot(beWithin(-14.3..<(-7.2)))

        // ClosedRange
        expect(0.1).to(beWithin(0.1...1.1))
        expect(5).to(beWithin(3...5))
        expect(-3).to(beWithin(-7...5))

        expect(0.3).toNot(beWithin(0.31...0.99))
        expect(3).toNot(beWithin(0...2))
        expect(-7.1).toNot(beWithin(-14.3...(-7.2)))
    }

    func testBeWithinNegativeMatches() {
        // Range
        failsWithErrorMessage("expected to be within range <(0.0..<2.1)>, got <2.1>") {
            expect(2.1).to(beWithin(0..<2.1))
        }
        failsWithErrorMessage("expected to not be within range <(0.0..<2.2)>, got <2.1>") {
            expect(2.1).toNot(beWithin(0..<2.2))
        }

        // ClosedRange
        failsWithErrorMessage("expected to be within range <(0.2...1.1)>, got <0.1>") {
            expect(0.1).to(beWithin(0.2...1.1))
        }
        failsWithErrorMessage("expected to not be within range <(0.31...0.99)>, got <0.31>") {
            expect(0.31).toNot(beWithin(0.31...0.99))
        }
    }
}
