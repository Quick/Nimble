#if !os(WASI)

#if canImport(CoreFoundation)
import CoreFoundation
#endif
import Dispatch
import Foundation

// Basically a re-implementation of Clock and InstantProtocol.
// This can be removed once we drop support for iOS < 16.
internal protocol NimbleClockProtocol: Sendable {
    associatedtype Instant: NimbleInstantProtocol

    func now() -> Instant

    func sleep(until: Instant) async throws
}

internal protocol NimbleInstantProtocol: Sendable, Comparable {
    associatedtype Interval: NimbleIntervalProtocol

    func advanced(byInterval: Interval) -> Self

    func intervalSince(_: Self) -> Interval
}

internal protocol NimbleIntervalProtocol: Sendable, Comparable {
    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Self) -> Self
    static func / (lhs: Self, rhs: Self) -> Self

    func rounded(_ rule: FloatingPointRoundingRule) -> Self
}

internal struct DateClock: NimbleClockProtocol {
    typealias Instant = Date

    func now() -> Instant {
        Date()
    }

    func sleep(until: Instant) async throws {
        try await Task.sleep(nanoseconds: UInt64(Swift.max(0, until.timeIntervalSinceNow * 1_000_000_000)))
    }
}

// Date is Sendable as of at least iOS 16.
// But as of Swift 5.9, it's still not Sendable in the open source version.
extension Date: @unchecked Sendable {}

extension Date: NimbleInstantProtocol {
    typealias Interval = NimbleTimeInterval

    func advanced(byInterval interval: NimbleTimeInterval) -> Date {
        advanced(by: interval.timeInterval)
    }

    func intervalSince(_ other: Date) -> NimbleTimeInterval {
        timeIntervalSince(other).nimbleInterval
    }
}

extension NimbleTimeInterval: NimbleIntervalProtocol {
    func rounded(_ rule: FloatingPointRoundingRule) -> NimbleTimeInterval {
        timeInterval.rounded(rule).nimbleInterval
    }

    static func + (lhs: NimbleTimeInterval, rhs: NimbleTimeInterval) -> NimbleTimeInterval {
        (lhs.timeInterval + rhs.timeInterval).nimbleInterval
    }

    static func - (lhs: NimbleTimeInterval, rhs: NimbleTimeInterval) -> NimbleTimeInterval {
        (lhs.timeInterval - rhs.timeInterval).nimbleInterval
    }

    static func * (lhs: NimbleTimeInterval, rhs: NimbleTimeInterval) -> NimbleTimeInterval {
        (lhs.timeInterval * rhs.timeInterval).nimbleInterval
    }

    static func / (lhs: NimbleTimeInterval, rhs: NimbleTimeInterval) -> NimbleTimeInterval {
        (lhs.timeInterval / rhs.timeInterval).nimbleInterval
    }

    public static func < (lhs: NimbleTimeInterval, rhs: NimbleTimeInterval) -> Bool {
        lhs.timeInterval < rhs.timeInterval
    }
}

// Similar to (made by directly referencing) swift-async-algorithm's AsyncTimerSequence.
// https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncTimerSequence.swift
// Only this one is compatible with OS versions that Nimble supports.
struct AsyncTimerSequence<Clock: NimbleClockProtocol>: AsyncSequence {
    typealias Element = Void
    let clock: Clock
    let interval: Clock.Instant.Interval

    struct AsyncIterator: AsyncIteratorProtocol {
        let clock: Clock
        let interval: Clock.Instant.Interval

        var last: Clock.Instant?

        func nextDeadline() -> Clock.Instant {
            let now = clock.now()

            let last = self.last ?? now
            let next = last.advanced(byInterval: interval)
            if next < now {
                let nextTimestep = interval * (now.intervalSince(next) / interval).rounded(.up)
                return last.advanced(byInterval: nextTimestep)
            } else {
                return next
            }
        }

        mutating func next() async -> Void? {
            let next = nextDeadline()
            do {
                try await clock.sleep(until: next)
            } catch {
                return nil
            }
            last = next
            return ()
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(clock: clock, interval: interval)
    }
}

extension AsyncTimerSequence<DateClock> {
    init(interval: NimbleTimeInterval) {
        self.init(clock: DateClock(), interval: interval)
    }
}

#endif // os(WASI)
