import Foundation

struct _EndWithMatcher<S where S: Sequence, S.GeneratorType.Element: Equatable>: Matcher {
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

struct _EndWithStringMatcher: Matcher {
    let endingSubstring: String

    func matches(actualExpression: Expression<String>) -> (pass: Bool, postfix: String)  {
        let actual = actualExpression.evaluate()
        let range = actual.rangeOfString(endingSubstring)
        return (range.endIndex == actual.endIndex, "end with <\(endingSubstring)>")
    }
}

struct _EndWithOrderedCollectionMatcher: Matcher {
    let endingElement: AnyObject

    func matches(actualExpression: Expression<TSOrderedCollection>) -> (pass: Bool, postfix: String) {
        let actual = actualExpression.evaluate()
        return (actual.indexOfObject(endingElement) == actual.count - 1, "end with <\(endingElement)>")
    }
}

func endWith<T: Equatable>(item: T) -> _EndWithMatcher<T[]> {
    return _EndWithMatcher(endingElement: item)
}

func endWith(item: AnyObject) -> _EndWithOrderedCollectionMatcher {
    return _EndWithOrderedCollectionMatcher(endingElement: item)
}

func endWith(substring: String) -> _EndWithStringMatcher {
    return _EndWithStringMatcher(endingSubstring: substring)
}
