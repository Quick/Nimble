import Foundation


// Implement this protocol if you want full control over to() and toNot() behaviors
// and completely emit the "expected (actual) to ..." message
protocol MatcherWithFullMessage {
    typealias ValueType
    func matches(actualExpression: Expression<ValueType>) -> (pass: Bool, message: String)
    func doesNotMatch(actualExpression: Expression<ValueType>) -> (pass: Bool, message: String)
}

// Implement this protocol if you just want a simplier matcher. The negation
// is provided for you automatically.
//
// Messages are in the form: "expected (actual) to (postfix)"
// Messages should always be returned incase the negation case is being performed.
protocol Matcher {
    typealias ValueType
    func matches(actualExpression: Expression<ValueType>) -> (pass: Bool, postfix: String)
}

// Protocol for objective-c objects that should support contain() matcher
@objc protocol TSContainer {
    func containsObject(object: AnyObject!) -> Bool
}
extension NSArray: TSContainer {}
extension NSSet: TSContainer {}
extension NSHashTable: TSContainer {}

// Protocol for objective-c objects that should support beginWith() and endWith() matcher
@objc protocol TSOrderedCollection {
    func indexOfObject(object: AnyObject!) -> Int
    var count: Int { get }
}
extension NSArray: TSOrderedCollection {}
