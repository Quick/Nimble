import XCTest
import Foundation
@testable import Nimble

final class AsyncTimerSequenceTest: XCTestCase {
    func testOutputsVoidAtSpecifiedIntervals() async throws {
        let clock = FakeClock()

        _ = await AsyncTimerSequence(clock: clock, interval: 1).collect(upTo: 4)

        expect(clock.recordedInstants).to(equal([
            FakeInstant(now: 0),
            FakeInstant(now: 1),
            FakeInstant(now: 2),
            FakeInstant(now: 3),
            FakeInstant(now: 4),
        ]))
    }

    func testOutputsVoidAtSpecifiedIntervals2() async throws {
        let clock = FakeClock()

        _ = await AsyncTimerSequence(clock: clock, interval: 2).collect(upTo: 4)

        expect(clock.recordedInstants).to(equal([
            FakeInstant(now: 0),
            FakeInstant(now: 2),
            FakeInstant(now: 4),
            FakeInstant(now: 6),
            FakeInstant(now: 8),
        ]))
    }
    func testOutputsVoidAtSpecifiedIntervals3() async throws {
        let clock = FakeClock()

        _ = await AsyncTimerSequence(clock: clock, interval: 3).collect(upTo: 4)

        expect(clock.recordedInstants).to(equal([
            FakeInstant(now: 0),
            FakeInstant(now: 3),
            FakeInstant(now: 6),
            FakeInstant(now: 9),
            FakeInstant(now: 12),
        ]))
    }
}

extension AsyncSequence {
    func collect(upTo: Int? = nil) async rethrows -> [Element] {
        var values = [Element]()
        for try await value in self {
            values.append(value)
            if let upTo, values.count >= upTo { break }
        }
        return values
    }
}

struct FakeClock: NimbleClockProtocol {
    typealias Instant = FakeInstant

    private final class Implementation: @unchecked Sendable {
        var _now = FakeInstant(now: 0)
        var now: FakeInstant {
            lock.lock()
            defer { lock.unlock() }
            return _now
        }

        var _recordedInstants: [FakeInstant] = [FakeInstant(now: 0)]
        var recordedInstants: [FakeInstant] {
            lock.lock()
            defer { lock.unlock() }
            return _recordedInstants
        }

        let lock = NSLock()

        func sleep(until: FakeInstant) {
            lock.lock()

            defer { lock.unlock() }

            _now = until
            _recordedInstants.append(_now)
        }
    }

    private let current = Implementation()

    var recordedInstants: [FakeInstant] { current.recordedInstants }

    func now() -> FakeInstant {
        current.now
    }

    func sleep(until: FakeInstant) async throws {
        current.sleep(until: until)
    }
}

struct FakeInstant: NimbleInstantProtocol {
    typealias Interval = Int

    private let now: Interval

    init(now: Interval) {
        self.now = now
    }

    func advanced(byInterval interval: Interval) -> FakeInstant {
        FakeInstant(now: self.now + interval)
    }

    func intervalSince(_ other: FakeInstant) -> Interval {
        now - other.now
    }

    static func < (lhs: FakeInstant, rhs: FakeInstant) -> Bool {
        lhs.now < rhs.now
    }
}

extension Int: NimbleIntervalProtocol {
    public func rounded(_ rule: FloatingPointRoundingRule) -> Int {
        self
    }
}
