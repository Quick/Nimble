import Foundation

protocol MatcherWithFullMessage {
    typealias ValueType
    func matches(actualExpression: Expression<ValueType>) -> (pass: Bool, message: String)
    func doesNotMatch(actualExpression: Expression<ValueType>) -> (pass: Bool, message: String)
}

protocol Matcher {
    typealias ValueType
    func matches(actualExpression: Expression<ValueType>) -> (pass: Bool, messagePostfix: String)
}
