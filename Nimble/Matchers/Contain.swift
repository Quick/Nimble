import Foundation

func contain<S: Sequence, T: Equatable where S.GeneratorType.Element == T>(items: T...) -> MatcherFunc<S> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "contain <\(_arrayAsString(items))>"
        let actual = actualExpression.evaluate()
        return _all(items) {
            return contains(actual, $0)
        }
    }
}

func contain(items: AnyObject?...) -> MatcherFunc<NMBContainer?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "contain <\(_arrayAsString(items))>"
        let actual = actualExpression.evaluate()
        return _all(items) { item in
            return actual && actual!.containsObject(item)
        }
    }
}

extension NMBObjCMatcher {
    class func containMatcher(expected: NSObject?) -> NMBObjCMatcher {
        return NMBObjCMatcher { actualBlock, failureMessage, location in
            let block: () -> NMBContainer? = ({
                if let value = actualBlock() as? NMBContainer {
                    return value
                }
                return nil
            })
            let expr = Expression(expression: block, location: location)
            return contain(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
