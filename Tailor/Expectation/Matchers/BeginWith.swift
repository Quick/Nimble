import Foundation

struct _BeginWith<S where S: Sequence, S.GeneratorType.Element: Equatable>: Matcher {
    let startingElement: S.GeneratorType.Element

    func matches(actualExpression: Expression<S>) -> (pass: Bool, messagePostfix: String)  {
        let actualSequence = actualExpression.evaluate()
        var actualGenerator = actualSequence.generate()
        let actual = actualGenerator.next()
        return (actual == startingElement, "begin with <\(startingElement)>")
    }
}

struct _BeginWithString: Matcher {
    let startingSubstring: String

    func matches(actualExpression: Expression<String>) -> (pass: Bool, messagePostfix: String)  {
        let actual = actualExpression.evaluate()
        let range = actual.rangeOfString(startingSubstring)
        return (range.startIndex == actual.startIndex, "begin with <\(startingSubstring)>")
    }
}

func beginWith<T: Equatable>(item: T) -> _BeginWith<T[]> {
    return _BeginWith(startingElement: item)
}

func beginWith(substring: String) -> _BeginWithString {
    return _BeginWithString(startingSubstring: substring)
}
