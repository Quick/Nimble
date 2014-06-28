import Foundation

func endWith<T: Equatable>(endingElement: T) -> FuncMatcherWrapper<T[]> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "end with <\(endingElement)>"

        var actualGenerator = actualExpression.evaluate().generate()
        var lastItem: T?
        var item: T?
        do {
            lastItem = item
            item = actualGenerator.next()
        } while(item)

        return lastItem == endingElement
    }
}

func endWith(endingElement: AnyObject) -> FuncMatcherWrapper<KICOrderedCollection> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "end with <\(endingElement)>"
        let actual = actualExpression.evaluate()
        return actual.indexOfObject(endingElement) == actual.count - 1
    }
}

func endWith(endingSubstring: String) -> FuncMatcherWrapper<String> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "end with <\(endingSubstring)>"
        let actual = actualExpression.evaluate()
        let range = actual.rangeOfString(endingSubstring)
        return range.endIndex == actual.endIndex
    }
}
