import Foundation

func _arrayAsString<T>(items: T[], joiner: String = ", ") -> String {
    return items.reduce("") { accum, item in
        let prefix = (accum.isEmpty ? "" : joiner)
        return accum + prefix + "\(item)"
    }
}

func contain<T: Equatable>(items: T...) -> MatcherFunc<T[]> {
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

func contain(substrings: String...) -> MatcherFunc<String> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "contain <\(_arrayAsString(substrings))>"
        let actual = actualExpression.evaluate()
        return _all(substrings) {
            return actual.rangeOfString($0).getLogicValue()
        }
    }
}
