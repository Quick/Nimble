import Foundation


// Implement this protocol if you want full control over to() and toNot() behaviors
protocol Matcher {
    typealias ValueType
    func matches(actualExpression: Expression<ValueType>, failureMessage: FailureMessage) -> Bool
    func doesNotMatch(actualExpression: Expression<ValueType>, failureMessage: FailureMessage) -> Bool
}

// Objective-C interface to a similar interface
@objc protocol KICMatcher {
    func matches(actualExpression: () -> NSObject?, failureMessage: FailureMessage, location: SourceLocation) -> Bool
}

// Implement this protocol if you just want a simplier matcher. The negation
// is provided for you automatically.
//
// If you just want a very simplified usage of BasicMatcher,
// @see MatcherFunc.
protocol BasicMatcher {
    typealias ValueType
    func matches(actualExpression: Expression<ValueType>, failureMessage: FailureMessage) -> Bool
}

// Protocol for types that support contain() matcher
@objc protocol KICContainer {
    func containsObject(object: AnyObject!) -> Bool
}
extension NSArray : KICContainer {}
extension NSSet : KICContainer {}
extension NSHashTable : KICContainer {}

// Protocol for types that support only beEmpty()
@objc protocol KICCollection {
    var count: Int { get }
}
extension NSSet : KICCollection {}
extension NSDictionary : KICCollection {}
extension NSHashTable : KICCollection {}

// Protocol for types that support beginWith(), endWith(), beEmpty() matchers
@objc protocol KICOrderedCollection : KICCollection {
    func indexOfObject(object: AnyObject!) -> Int
}
extension NSArray : KICOrderedCollection {}

// Protocol for types to support beCloseTo() matcher
@objc protocol KICDoubleConvertible {
    var doubleValue: CDouble { get }
}
extension NSNumber : KICDoubleConvertible { }
extension NSDecimalNumber : KICDoubleConvertible { } // TODO: not the best to downsize

// Protocol for types to support beLessThan(), beLessThanOrEqualTo(),
//  beGreaterThan(), beGreaterThanOrEqualTo(), and equal() matchers.
//
// Types that conform to Swift's Comparable protocol will work implicitly too
@objc protocol KICComparable {
    func KIC_compare(otherObject: KICComparable!) -> NSComparisonResult
}
extension NSNumber : KICComparable {
    func KIC_compare(otherObject: KICComparable!) -> NSComparisonResult {
        return compare(otherObject as NSNumber)
    }
}
extension NSString : KICComparable {
    func KIC_compare(otherObject: KICComparable!) -> NSComparisonResult {
        return compare(otherObject as NSString)
    }
}
