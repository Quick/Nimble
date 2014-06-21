import Foundation

struct _Contain<S where S: Sequence, S.GeneratorType.Element: Equatable>: Matcher {
    let expectedItem: S.GeneratorType.Element

    func matches(actualExpression: Expression<S>) -> (pass: Bool, postfix: String)  {
        let actual = actualExpression.evaluate()
        let pass = contains(actual, expectedItem)
        return (pass, "contain <\(expectedItem)>")
    }
}

struct _ContainSubstring: Matcher {
    let substring: String

    func matches(actualExpression: Expression<String>) -> (pass: Bool, postfix: String) {
        let actual = actualExpression.evaluate()
        let pass = actual.rangeOfString(substring).getLogicValue()
        return (pass, "contain <\(substring)>")
    }
}

func contain<T: Equatable>(item: T) -> _Contain<T[]> {
    return _Contain(expectedItem: item)
}

func contain(item: String) -> _ContainSubstring {
    return _ContainSubstring(substring: item)
}
