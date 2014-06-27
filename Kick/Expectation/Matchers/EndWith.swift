import Foundation

func endWith<T: Equatable>(endingElement: T) -> FuncMatcherWrapper<T[]> {
    return DefineMatcher { actualExpression in
        let actualSequence = actualExpression.evaluate()
        var actualGenerator = actualSequence.generate()
        var lastItem: T?
        var item: T?
        do {
            lastItem = item
            item = actualGenerator.next()
        } while(item)

        return (lastItem == endingElement, "end with <\(endingElement)>")
    }
}

func endWith(endingElement: AnyObject) -> FuncMatcherWrapper<KICOrderedCollection> {
    return DefineMatcher { actualExpression in
        let actual = actualExpression.evaluate()
        return (actual.indexOfObject(endingElement) == actual.count - 1, "end with <\(endingElement)>")
    }
}

func endWith(endingSubstring: String) -> FuncMatcherWrapper<String> {
    return DefineMatcher { actualExpression in
        let actual = actualExpression.evaluate()
        let range = actual.rangeOfString(endingSubstring)
        return (range.endIndex == actual.endIndex, "end with <\(endingSubstring)>")
    }
}
