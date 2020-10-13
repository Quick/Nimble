import Foundation
import XCTest
import Nimble

final class BeWithinTest: XCTestCase {
    func testBeWithin() {
        expect(0.1).to(beWithin(0.1...1.1))
        expect(5).to(beWithin(3...5))
        expect(-3).to(beWithin(-7...5))

        expect(0.3).toNot(beWithin(0.31...0.99))
        expect(2).toNot(beWithin(0..<2))
        expect(-7.1).toNot(beWithin(-14.3..<(-7.2)))

        failsWithErrorMessage("expected to be within range <(0.1...1.1)>, got <0>") {
            expect(0).to(beWithin(0.1...1.1))
        }

        failsWithErrorMessage("expected to be within range <(0..<2)>, got <2>") {
            expect(2).to(beWithin(0..<2))
        }

        failsWithErrorMessage("expected to not be within range <(0.31...0.99)>, got <0.31>") {
            expect(0.31).toNot(beWithin(0.31...0.99))
        }

        failsWithErrorMessage("expected to not be within range <(0.0..<2.1)>, got <2>") {
            expect(2).toNot(beWithin(0..<2.1))
        }
    }
}
