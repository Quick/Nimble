import Foundation

public func endWith<S: SequenceType, T: Equatable where S.Generator.Element == T>(endingElement: T) -> NonNilMatcherFunc<S> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "end with <\(endingElement)>"

        if let actualValue = actualExpression.evaluate() {
            var actualGenerator = actualValue.generate()
            var lastItem: T?
            var item: T?
            do {
                lastItem = item
                item = actualGenerator.next()
            } while(item != nil)
            
            return lastItem == endingElement
        }
        return false
    }
}

public func endWith(endingElement: AnyObject) -> NonNilMatcherFunc<NMBOrderedCollection> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "end with <\(endingElement)>"
        let collection = actualExpression.evaluate()
        return collection != nil && collection!.indexOfObject(endingElement) == collection!.count - 1
    }
}

public func endWith(endingSubstring: String) -> NonNilMatcherFunc<String> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "end with <\(endingSubstring)>"
        if let collection = actualExpression.evaluate() {
            let range = collection.rangeOfString(endingSubstring)
            return range != nil && range!.endIndex == collection.endIndex
        }
        return false
    }
}

extension NMBObjCMatcher {
    public class func endWithMatcher(expected: AnyObject) -> NMBObjCMatcher {
        return NMBObjCMatcher { actualBlock, failureMessage, location in
            let actual = actualBlock()
            if let actualString = actual as? String {
                let expr = Expression(expression: ({ actualString }), location: location)
                let matcher = NonNilMatcherWrapper(NonNilBasicMatcherWrapper(endWith(expected as String)))
                return matcher.matches(expr, failureMessage: failureMessage)
            } else {
                let expr = Expression(expression: ({ actual as? NMBOrderedCollection }), location: location)
                let matcher = NonNilMatcherWrapper(NonNilBasicMatcherWrapper(endWith(expected)))
                return matcher.matches(expr, failureMessage: failureMessage)
            }
        }
    }
}
