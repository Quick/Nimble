import Foundation

func endWith<S: Sequence, T: Equatable where S.GeneratorType.Element == T>(endingElement: T) -> MatcherFunc<S> {
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

func endWith(endingElement: AnyObject) -> MatcherFunc<KICOrderedCollection> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "end with <\(endingElement)>"
        let actual = actualExpression.evaluate()
        return actual.indexOfObject(endingElement) == actual.count - 1
    }
}

func endWith(endingSubstring: String) -> MatcherFunc<String> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "end with <\(endingSubstring)>"
        let actual = actualExpression.evaluate()
        let range = actual.rangeOfString(endingSubstring)
        return range.endIndex == actual.endIndex
    }
}
