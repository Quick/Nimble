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

func endWith(endingElement: AnyObject) -> MatcherFunc<NMBOrderedCollection?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "end with <\(endingElement)>"
        let collection = actualExpression.evaluate()
        return collection && collection!.indexOfObject(endingElement) == collection!.count - 1
    }
}

func endWith(endingSubstring: String) -> MatcherFunc<String> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "end with <\(endingSubstring)>"
        let collection = actualExpression.evaluate()
        let range = collection.rangeOfString(endingSubstring)
        return range && range!.endIndex == collection.endIndex
    }
}

extension NMBObjCMatcher {
    public class func endWithMatcher(expected: AnyObject) -> NMBObjCMatcher {
        return NMBObjCMatcher { actualBlock, failureMessage, location in
            let actual = actualBlock()
            if let actualString = actual as? String {
                let expr = Expression(expression: ({ actualString }), location: location)
                return endWith(expected as NSString).matches(expr, failureMessage: failureMessage)
            } else {
                let expr = Expression(expression: ({ actual as? NMBOrderedCollection }), location: location)
                return endWith(expected).matches(expr, failureMessage: failureMessage)
            }
        }
    }
}
