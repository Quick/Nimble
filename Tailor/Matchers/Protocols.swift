import Foundation

protocol MatcherWithFullMessage {
    typealias ValueType
    func matches(actualExpression: () -> ValueType) -> (pass: Bool, message: String)
    func doesNotMatch(actualExpression: () -> ValueType) -> (pass: Bool, message: String)
}

protocol Matcher {
    typealias ValueType
    func matches(actualExpression: () -> ValueType) -> (pass: Bool, messagePostfix: String)
}
