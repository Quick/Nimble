import Foundation

struct _EndWith<S where S: Sequence, S.GeneratorType.Element: Equatable>: Matcher {
    let endingElement: S.GeneratorType.Element

    func matches(actualExpression: Expression<S>) -> (pass: Bool, postfix: String)  {
        let actualSequence = actualExpression.evaluate()
        var actualGenerator = actualSequence.generate()
        var lastItem: S.GeneratorType.Element?
        var item: S.GeneratorType.Element?
        do {
            lastItem = item
            item = actualGenerator.next()
        } while(item)

        return (lastItem == endingElement, "end with <\(endingElement)>")
    }
}

struct _EndWithString: Matcher {
    let endingSubstring: String

    func matches(actualExpression: Expression<String>) -> (pass: Bool, postfix: String)  {
        let actual = actualExpression.evaluate()
        let range = actual.rangeOfString(endingSubstring)
        return (range.endIndex == actual.endIndex, "end with <\(endingSubstring)>")
    }
}

func endWith<T: Equatable>(item: T) -> _EndWith<T[]> {
    return _EndWith(endingElement: item)
}

func endWith(substring: String) -> _EndWithString {
    return _EndWithString(endingSubstring: substring)
}
