import Foundation

public func beginWith<S: Sequence, T: Equatable where S.GeneratorType.Element == T>(startingElement: T) -> MatcherFunc<S> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "begin with <\(startingElement)>"
        var actualGenerator = actualExpression.evaluate().generate()
        return actualGenerator.next() == startingElement
    }
}

public func beginWith(startingElement: AnyObject) -> MatcherFunc<NMBOrderedCollection?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "begin with <\(startingElement)>"
        let collection = actualExpression.evaluate()
        return collection && collection!.indexOfObject(startingElement) == 0
    }
}

public func beginWith(startingSubstring: String) -> MatcherFunc<String> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "begin with <\(startingSubstring)>"
        let actual = actualExpression.evaluate()
        let range = actual.rangeOfString(startingSubstring)
        return range && range!.startIndex == actual.startIndex
    }
}

extension NMBObjCMatcher {
    public class func beginWithMatcher(expected: AnyObject) -> NMBObjCMatcher {
        return NMBObjCMatcher { actualBlock, failureMessage, location in
            let actual = actualBlock()
            if let actualString = actual as? String {
                let expr = Expression(expression: ({ actualString }), location: location)
                return beginWith(expected as NSString).matches(expr, failureMessage: failureMessage)
            } else {
                let expr = Expression(expression: ({ actual as? NMBOrderedCollection }), location: location)
                return beginWith(expected).matches(expr, failureMessage: failureMessage)
            }
        }
    }
}
