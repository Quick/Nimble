import Foundation

struct _BeginWithSequenceMatcher<S where S: Sequence, S.GeneratorType.Element: Equatable>: BasicMatcher {
    let startingElement: S.GeneratorType.Element

    func matches(actualExpression: Expression<S>) -> (pass: Bool, postfix: String)  {
        let actualSequence = actualExpression.evaluate()
        var actualGenerator = actualSequence.generate()
        let actual = actualGenerator.next()
        return (actual == startingElement, "begin with <\(startingElement)>")
    }
}

struct _BeginWithStringMatcher: BasicMatcher {
    let startingSubstring: String

    func matches(actualExpression: Expression<String>) -> (pass: Bool, postfix: String)  {
        let actual = actualExpression.evaluate()
        let range = actual.rangeOfString(startingSubstring)
        return (range.startIndex == actual.startIndex, "begin with <\(startingSubstring)>")
    }
}

struct _BeginWithOrderedCollectionMatcher: BasicMatcher {
    let startingElement: AnyObject

    func matches(actualExpression: Expression<KICOrderedCollection>) -> (pass: Bool, postfix: String) {
        let actual = actualExpression.evaluate()
        return (actual.indexOfObject(startingElement) == 0, "begin with <\(startingElement)>")
    }
}

func beginWith<T: Equatable>(item: T) -> _BeginWithSequenceMatcher<T[]> {
    return _BeginWithSequenceMatcher(startingElement: item)
}

func beginWith(item: AnyObject) -> _BeginWithOrderedCollectionMatcher {
    return _BeginWithOrderedCollectionMatcher(startingElement: item)
}

func beginWith(substring: String) -> _BeginWithStringMatcher {
    return _BeginWithStringMatcher(startingSubstring: substring)
}
