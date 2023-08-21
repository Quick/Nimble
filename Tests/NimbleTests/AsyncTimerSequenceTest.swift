import XCTest
import Foundation
@testable import Nimble

final class AsyncTimerSequenceTest: XCTestCase {
    func testOutputsVoidAtSpecifiedIntervals() async throws {
        var times: [Date] = []
        for try await _ in AsyncTimerSequence(interval: .milliseconds(10)) {
            times.append(Date())
            if times.count > 4 { break }
        }

        expect(times[1].timeIntervalSince(times[0]) * 1_000).to(beCloseTo(10, within: 5))
        expect(times[2].timeIntervalSince(times[1]) * 1_000).to(beCloseTo(10, within: 5))
        expect(times[3].timeIntervalSince(times[2]) * 1_000).to(beCloseTo(10, within: 5))
        expect(times[4].timeIntervalSince(times[3]) * 1_000).to(beCloseTo(10, within: 5))
    }
}
