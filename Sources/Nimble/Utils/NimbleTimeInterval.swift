/// A reimplementation of `DispatchTimeInterval` without the `never` case, and conforming to `Sendable`.
public enum NimbleTimeInterval: Sendable, Equatable {
    case seconds(Int)
    case milliseconds(Int)
    case microseconds(Int)
    case nanoseconds(Int)
}

extension NimbleTimeInterval: CustomStringConvertible {
    // ** Note: We cannot simply divide the time interval because NimbleTimeInterval associated value type is Int
    internal var divided: NimbleTimeInterval {
        switch self {
        case let .seconds(val): return val < 2 ? .milliseconds(Int(Float(val)/2*1000)) : .seconds(val/2)
        case let .milliseconds(val): return .milliseconds(val/2)
        case let .microseconds(val): return .microseconds(val/2)
        case let .nanoseconds(val): return .nanoseconds(val/2)
        }
    }

    public var description: String {
        switch self {
        case let .seconds(val): return val == 1 ? "\(Float(val)) second" : "\(Float(val)) seconds"
        case let .milliseconds(val): return "\(Float(val)/1_000) seconds"
        case let .microseconds(val): return "\(Float(val)/1_000_000) seconds"
        case let .nanoseconds(val): return "\(Float(val)/1_000_000_000) seconds"
        }
    }
}

#if canImport(Foundation)
import typealias Foundation.TimeInterval

extension TimeInterval {
    var nimbleInterval: NimbleTimeInterval {
        let microseconds = Int64(self * TimeInterval(USEC_PER_SEC))
        // perhaps use nanoseconds, though would more often be > Int.max
        return microseconds < Int.max ? .microseconds(Int(microseconds)) : .seconds(Int(self))
    }
}
#endif // canImport(Foundation)

#if !os(WASI)
import Dispatch

#if canImport(CDispatch)
import CDispatch
#endif

extension NimbleTimeInterval {
    public var dispatchTimeInterval: DispatchTimeInterval {
        switch self {
        case .seconds(let int):
            return .seconds(int)
        case .milliseconds(let int):
            return .milliseconds(int)
        case .microseconds(let int):
            return .microseconds(int)
        case .nanoseconds(let int):
            return .nanoseconds(int)
        }
    }
}

@available(macOS 13, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension NimbleTimeInterval {
    public var duration: Duration {
        switch self {
        case .seconds(let int):
            return .seconds(int)
        case .milliseconds(let int):
            return .milliseconds(int)
        case .microseconds(let int):
            return .microseconds(int)
        case .nanoseconds(let int):
            return .nanoseconds(int)
        }
    }

    public init(duration: Duration) {
        let (seconds, attoseconds) = duration.components

        if attoseconds == 0 {
            self = .seconds(Int(seconds))
            return
        }

        let nanoseconds = attoseconds / 1_000_000_000
        if (nanoseconds % 1_000_000) == 0 {
            self = .milliseconds((Int(seconds) * 1_000) + Int(nanoseconds / 1_000_000))
        } else if (nanoseconds % 1_000) == 0 {
            self = .microseconds((Int(seconds) * 1_000_000) + Int(nanoseconds / 1_000))
        } else {
            self = .nanoseconds((Int(seconds) * 1_000_000_000) + Int(nanoseconds))
        }
    }
}

#endif // #if !os(WASI)
