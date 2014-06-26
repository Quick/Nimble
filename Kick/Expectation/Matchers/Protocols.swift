import Foundation


// Implement this protocol if you want full control over to() and toNot() behaviors
// and completely emit the "expected (actual) to ..." message
protocol Matcher {
    typealias ValueType
    func matches(actualExpression: Expression<ValueType>) -> (Bool, String)
    func doesNotMatch(actualExpression: Expression<ValueType>) -> (Bool, String)
}

// Implement this protocol if you just want a simplier matcher. The negation
// is provided for you automatically.
//
// Messages are in the form: "expected (actual) to (postfix)"
// Messages should always be returned incase the negation case is being performed.
protocol BasicMatcher {
    typealias ValueType
    func matches(actualExpression: Expression<ValueType>) -> (pass: Bool, postfix: String)
}

// Protocol for objective-c objects that support contain() matcher
@objc protocol KICContainer {
    func containsObject(object: AnyObject!) -> Bool
}
extension NSArray: KICContainer {}
extension NSSet: KICContainer {}
extension NSHashTable: KICContainer {}

// Protocol for objective-c objects that support beginWith() and endWith() matcher
@objc protocol KICOrderedCollection {
    func indexOfObject(object: AnyObject!) -> Int
    var count: Int { get }
}
extension NSArray: KICOrderedCollection {}

// Protocol for objective-c objects to support beCloseTo() matcher
@objc protocol KICDoubleConvertible {
    var doubleValue: CDouble { get }
}

extension NSNumber : KICDoubleConvertible { }