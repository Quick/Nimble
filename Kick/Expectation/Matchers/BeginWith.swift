import Foundation

func beginWith<T: Equatable>(startingElement: T) -> FuncMatcherWrapper<T[]> {
    return DefineMatcher { actualExpression in
        let actualSequence = actualExpression.evaluate()
        var actualGenerator = actualSequence.generate()
        let actual = actualGenerator.next()
        return (actual == startingElement, "begin with <\(startingElement)>")
    }
}

func beginWith(startingElement: AnyObject) -> FuncMatcherWrapper<KICOrderedCollection> {
    return DefineMatcher { actualExpression in
        let actual = actualExpression.evaluate()
        return (actual.indexOfObject(startingElement) == 0, "begin with <\(startingElement)>")
    }
}

func beginWith(startingSubstring: String) -> FuncMatcherWrapper<String> {
    return DefineMatcher { actualExpression in
        let actual = actualExpression.evaluate()
        let range = actual.rangeOfString(startingSubstring)
        return (range.startIndex == actual.startIndex, "begin with <\(startingSubstring)>")
    }
}
