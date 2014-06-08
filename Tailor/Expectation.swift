import Foundation

struct Expectation<T> {
    let file: String
    let line: Int
    let expression: Expression<T>
    let assertion: AssertionHandler = CurrentAssertionHandler

    init(closure: () -> T, file: String, line: Int) {
        self.expression = Expression(closure: closure)
        self.file = file
        self.line = line
    }

    func verify(pass: Bool, message: String) {
        assertion.assert(pass, message: message, file: file, line: line)
    }

    func to<U where U: MatcherWithFullMessage, U.ValueType == T>(matcher: U) {
        let (pass, message) = matcher.matches(expression)
        verify(pass, message: message)
    }

    func toNot<U where U: MatcherWithFullMessage, U.ValueType == T>(matcher: U) {
        let (pass, message) = matcher.doesNotMatch(expression)
        verify(pass, message: message)
    }

    func to<U where U: Matcher, U.ValueType == T>(matcher: U) {
        let actualValue = expression.evaluateIfNeeded()
        let (pass, messagePostfix) = matcher.matches(expression)
        verify(pass, message: "expected <\(actualValue)> to \(messagePostfix)")
    }

    func toNot<U where U: Matcher, U.ValueType == T>(matcher: U) {
        let actualValue = expression.evaluateIfNeeded()
        let (pass, messagePostfix) = matcher.matches(expression)
        verify(!pass, message: "expected <\(actualValue)> to not \(messagePostfix)")
    }
}
