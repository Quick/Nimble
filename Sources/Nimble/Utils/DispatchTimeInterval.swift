import Dispatch

extension DispatchTimeInterval {
    // ** Note: We cannot simply divide the timeinterval because DispatchTimeInterval associated value type is Int
    public var divided: DispatchTimeInterval {
        switch self {
        case let .seconds(val): return val < 2 ? .milliseconds(Int(Float(val)/2*1000)) : .seconds(val/2)
        case let .milliseconds(val): return .milliseconds(val/2)
        case let .microseconds(val): return .microseconds(val/2)
        case let .nanoseconds(val): return .nanoseconds(val/2)
        case .never: return .never
        @unknown default: fatalError("Unknow DispatchTimeInterval value")
        }
    }

    var description: String {
        switch self {
        case let .seconds(val): return val == 1 ? "\(Float(val)) second" : "\(Float(val)) seconds"
        case let .milliseconds(val): return "\(Float(val)/1000) seconds"
        case let .microseconds(val): return "\(Float(val)/1000000) seconds"
        case let .nanoseconds(val): return "\(Float(val)/1000000000) seconds"
        default: fatalError("Unknow DispatchTimeInterval value")
        }
    }
}

extension TimeInterval {
    // swiftlint:disable line_length
    public var dispatchInterval: DispatchTimeInterval {
        let microseconds = Int64(self * TimeInterval(USEC_PER_SEC))
        // perhaps use nanoseconds, though would more often be > Int.max
        return microseconds < Int.max ? DispatchTimeInterval.microseconds(Int(microseconds)) : DispatchTimeInterval.seconds(Int(self))
    }
}
