import Nimble
import XCTest
import Foundation

final class NimbleTimeIntervalTests: XCTestCase {
    func testMultiply() {
        expect(NimbleTimeInterval.seconds(1) * 2) == NimbleTimeInterval.seconds(2)
        expect(2 * NimbleTimeInterval.seconds(1)) == NimbleTimeInterval.seconds(2)

        expect(NimbleTimeInterval.milliseconds(1) * 2) == NimbleTimeInterval.milliseconds(2)
        expect(2 * NimbleTimeInterval.milliseconds(1)) == NimbleTimeInterval.milliseconds(2)

        expect(NimbleTimeInterval.microseconds(1) * 2) == NimbleTimeInterval.microseconds(2)
        expect(2 * NimbleTimeInterval.microseconds(1)) == NimbleTimeInterval.microseconds(2)

        expect(NimbleTimeInterval.nanoseconds(1) * 2) == NimbleTimeInterval.nanoseconds(2)
        expect(2 * NimbleTimeInterval.nanoseconds(1)) == NimbleTimeInterval.nanoseconds(2)
    }

    @available(macOS 13, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    func testToDuration() throws {
        expect(NimbleTimeInterval.seconds(1).duration).to(equal(Duration.seconds(1)))
        expect(NimbleTimeInterval.milliseconds(10).duration).to(equal(Duration.milliseconds(10)))
        expect(NimbleTimeInterval.microseconds(20).duration).to(equal(Duration.microseconds(20)))
        expect(NimbleTimeInterval.nanoseconds(30).duration).to(equal(Duration.nanoseconds(30)))
    }

    @available(macOS 13, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    func testFromDuration() throws {
        expect(NimbleTimeInterval(duration: Duration.seconds(10))).to(equal(.seconds(10)))

        expect(NimbleTimeInterval(duration: Duration.milliseconds(1000))).to(equal(.seconds(1)))
        expect(NimbleTimeInterval(duration: Duration.milliseconds(1001))).to(equal(.milliseconds(1001)))

        expect(NimbleTimeInterval(duration: Duration.microseconds(1_000_000))).to(equal(.seconds(1)))
        expect(NimbleTimeInterval(duration: Duration.microseconds(1_001_000))).to(equal(.milliseconds(1001)))
        expect(NimbleTimeInterval(duration: Duration.microseconds(1_001_010))).to(equal(.microseconds(1_001_010)))

        expect(NimbleTimeInterval(duration: Duration.nanoseconds(1_000_000_000))).to(equal(.seconds(1)))
        expect(NimbleTimeInterval(duration: Duration.nanoseconds(1_001_000_000))).to(equal(.milliseconds(1001)))
        expect(NimbleTimeInterval(duration: Duration.nanoseconds(1_001_010_000))).to(equal(.microseconds(1_001_010)))
        expect(NimbleTimeInterval(duration: Duration.nanoseconds(1_001_010_100))).to(equal(.nanoseconds(1_001_010_100)))
    }
}
