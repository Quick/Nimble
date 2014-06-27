import Foundation

func contain(item: AnyObject?) -> FuncMatcherWrapper<KICContainer> {
    return DefineMatcher { actualExpression in
        let actual = actualExpression.evaluate()
        let pass = actual.containsObject(item)
        return (pass, "contain <\(item)>")
    }
}

func contain<T: Equatable>(item: T) -> FuncMatcherWrapper<T[]> {
    return DefineMatcher { actualExpression in
        let actual = actualExpression.evaluate()
        let pass = contains(actual, item)
        return (pass, "contain <\(item)>")
    }
}

func contain(substring: String) -> FuncMatcherWrapper<String> {
    return DefineMatcher { actualExpression in
        let actual = actualExpression.evaluate()
        let pass = actual.rangeOfString(substring).getLogicValue()
        return (pass, "contain <\(substring)>")
    }
}
