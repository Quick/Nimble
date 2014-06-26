import Foundation

struct _ContainSequenceMatcher<S where S: Sequence, S.GeneratorType.Element: Equatable>: BasicMatcher {
    let expectedItem: S.GeneratorType.Element

    func matches(actualExpression: Expression<S>) -> (pass: Bool, postfix: String)  {
        let actual = actualExpression.evaluate()
        let pass = contains(actual, expectedItem)
        return (pass, "contain <\(expectedItem)>")
    }
}

struct _ContainSubstringMatcher: BasicMatcher {
    let substring: String

    func matches(actualExpression: Expression<String>) -> (pass: Bool, postfix: String) {
        let actual = actualExpression.evaluate()
        let pass = actual.rangeOfString(substring).getLogicValue()
        return (pass, "contain <\(substring)>")
    }
}

struct _ContainerMatcher: BasicMatcher {
    let item: AnyObject?

    func matches(actualExpression: Expression<KICContainer>) -> (pass: Bool, postfix: String) {
        let actual = actualExpression.evaluate()
        let pass = actual.containsObject(item)
        return (pass, "contain <\(item)>")
    }
}

func contain(item: AnyObject?) -> _ContainerMatcher {
    return _ContainerMatcher(item: item)
}

func contain<T: Equatable>(item: T) -> _ContainSequenceMatcher<T[]> {
    return _ContainSequenceMatcher(expectedItem: item)
}

func contain(item: String) -> _ContainSubstringMatcher {
    return _ContainSubstringMatcher(substring: item)
}
