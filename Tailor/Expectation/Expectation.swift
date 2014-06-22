import Foundation

struct Expectation<T> {
    let expression: Expression<T>
    let assertion: AssertionHandler = CurrentAssertionHandler

    init(expression: Expression<T>) {
        self.expression = expression
    }

    func verify(pass: Bool, message: String) {
        assertion.assert(pass, message: message, location: expression.location)
    }

    func to<U where U: Matcher, U.ValueType == T>(matcher: U) {
        let (pass, message) = matcher.matches(expression)
        verify(pass, message: message)
    }

    func toNot<U where U: Matcher, U.ValueType == T>(matcher: U) {
        let (pass, message) = matcher.doesNotMatch(expression)
        verify(pass, message: message)
    }

    // see FullMatcherWrapper and AsyncMatcherWrapper for extensions
}
