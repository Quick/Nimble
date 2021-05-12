import Foundation
// `CGFloat` is in Foundation (swift-corelibs-foundation) on Linux.
#if canImport(Darwin)
    import CoreGraphics
#endif

/// Protocol for types that support contain() matcher.
public protocol NMBContainer {
    func contains(_ anObject: Any) -> Bool
}

#if canImport(Darwin)
// swiftlint:disable:next todo
// FIXME: NSHashTable can not conform to NMBContainer since swift-DEVELOPMENT-SNAPSHOT-2016-04-25-a
// extension NSHashTable : NMBContainer {} // Corelibs Foundation does not include this class yet
#endif

extension NSArray: NMBContainer {}
extension NSSet: NMBContainer {}

/// Protocol for types that support only beEmpty(), haveCount() matchers
public protocol NMBCollection {
    var count: Int { get }
}

#if canImport(Darwin)
extension NSHashTable: NMBCollection {} // Corelibs Foundation does not include these classes yet
extension NSMapTable: NMBCollection {}
#endif

extension NSSet: NMBCollection {}
extension NSIndexSet: NMBCollection {}
extension NSDictionary: NMBCollection {}

/// Protocol for types that support beginWith(), endWith(), beEmpty() matchers
public protocol NMBOrderedCollection: NMBCollection {
    func object(at index: Int) -> Any
}

extension NSArray: NMBOrderedCollection {}

public protocol NMBDoubleConvertible {
    var doubleValue: CDouble { get }
}

extension NSNumber: NMBDoubleConvertible {
}

#if !os(WASI)
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
    formatter.locale = Locale(identifier: "en_US_POSIX")

    return formatter
}()
#endif

extension Date: NMBDoubleConvertible {
    public var doubleValue: CDouble {
        return self.timeIntervalSinceReferenceDate
    }
}

extension NSDate: NMBDoubleConvertible {
    public var doubleValue: CDouble {
        return self.timeIntervalSinceReferenceDate
    }
}

#if !os(WASI)
extension Date: TestOutputStringConvertible {
    public var testDescription: String {
        return dateFormatter.string(from: self)
    }
}

extension NSDate: TestOutputStringConvertible {
    public var testDescription: String {
        return dateFormatter.string(from: Date(timeIntervalSinceReferenceDate: self.timeIntervalSinceReferenceDate))
    }
}
#endif

#if canImport(Darwin)
/// Protocol for types to support beLessThan(), beLessThanOrEqualTo(),
///  beGreaterThan(), beGreaterThanOrEqualTo(), and equal() matchers.
///
/// Types that conform to Swift's Comparable protocol will work implicitly too
@objc public protocol NMBComparable {
    func NMB_compare(_ otherObject: NMBComparable!) -> ComparisonResult
}

extension NSNumber: NMBComparable {
    public func NMB_compare(_ otherObject: NMBComparable!) -> ComparisonResult {
        // swiftlint:disable:next force_cast
        return compare(otherObject as! NSNumber)
    }
}
extension NSString: NMBComparable {
    public func NMB_compare(_ otherObject: NMBComparable!) -> ComparisonResult {
        // swiftlint:disable:next force_cast
        return compare(otherObject as! String)
    }
}
#endif
