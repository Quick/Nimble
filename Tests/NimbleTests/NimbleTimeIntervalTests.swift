import Nimble
import XCTest

@available(macOS 13, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
final class NimbleTimeIntervalTests: XCTestCase {
    func testToDuration() {
        expect(NimbleTimeInterval.seconds(1).duration).to(equal(Duration.seconds(1)))
        expect(NimbleTimeInterval.milliseconds(10).duration).to(equal(Duration.milliseconds(10)))
        expect(NimbleTimeInterval.microseconds(20).duration).to(equal(Duration.microseconds(20)))
        expect(NimbleTimeInterval.nanoseconds(30).duration).to(equal(Duration.nanoseconds(30)))
    }

    func testFromDuration() {
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
