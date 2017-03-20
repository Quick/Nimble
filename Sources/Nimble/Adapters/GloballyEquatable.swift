// MARK: OptionalType

public protocol OptionalType {}
extension Optional: OptionalType {}

// MARK: GloballyEquatable

// In order to use GloballyEquatable, conform to Equatable
public protocol GloballyEquatable {
    func isEqualTo(_ other: GloballyEquatable) -> Bool
}

public extension GloballyEquatable where Self: Equatable {
    public func isEqualTo(_ other: GloballyEquatable) -> Bool {
        // if 'self' is non-optional and 'other' is optional and other's .Some's associated value's type equals self's type
        // then the if let below will auto unwrap 'other' to be the non-optional version of self's type
        if type(of: self) != type(of: other) {
            return false
        }

        if let other = other as? Self {
            return self == other
        }

        return false
    }
}

public extension GloballyEquatable where Self: OptionalType {
    public func isEqualTo(_ other: GloballyEquatable) -> Bool {
        if type(of: self) != type(of: other) {
            return false
        }

        let selfMirror = Mirror(reflecting: self)
        let otherMirror = Mirror(reflecting: other)

        guard selfMirror.displayStyle == .optional else {
            assertionFailure("\(type(of: self)) should NOT conform to OptionalType, this is reserved for Optional<Wrapped>")
            return false
        }
        guard otherMirror.displayStyle == .optional else {
            assertionFailure("\(type(of: other)) should NOT conform to OptionalType, this is reserved for Optional<Wrapped>")
            return false
        }

        let selfsWrappedValue = selfMirror.children.first?.value
        let othersWrappedValue = otherMirror.children.first?.value

        if selfsWrappedValue == nil && othersWrappedValue == nil {
            return true
        }
        if selfsWrappedValue == nil || othersWrappedValue == nil {
            return false
        }

        guard let selfsContainedValueAsGE = selfsWrappedValue as? GloballyEquatable else {
            assertionFailure("\(type(of: selfsWrappedValue)) does NOT conform to GloballyEquatable")
            return false
        }
        guard let othersContainedValueAsGE = othersWrappedValue as? GloballyEquatable else {
            assertionFailure("\(type(of: othersWrappedValue)) does NOT conform to GloballyEquatable")
            return false
        }

        return selfsContainedValueAsGE.isEqualTo(othersContainedValueAsGE)
    }
}
