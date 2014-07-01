import Foundation

func contain<S: Sequence, T: Equatable where S.GeneratorType.Element == T>(items: T...) -> MatcherFunc<S> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "contain <\(_arrayAsString(items))>"
        let actual = actualExpression.evaluate()
        return _all(items) {
            return contains(actual, $0)
        }
    }
}

func contain(items: AnyObject?...) -> MatcherFunc<KICContainer> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "contain <\(_arrayAsString(items))>"
        let actual = actualExpression.evaluate()
        return _all(items) {
            return actual.containsObject($0)
        }
    }
}
