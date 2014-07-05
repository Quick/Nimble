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

func contain(items: AnyObject?...) -> MatcherFunc<KICContainer?> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "contain <\(_arrayAsString(items))>"
        let actual = actualExpression.evaluate()
        return _all(items) { item in
            return actual && actual!.containsObject(item)
        }
    }
}

extension KICObjCMatcher {
    class func containMatcher(expected: NSObject?) -> KICObjCMatcher {
        return KICObjCMatcher { actualBlock, failureMessage, location in
            let block: () -> KICContainer? = ({
                if let value = actualBlock() as? KICContainer {
                    return value
                }
                return nil
            })
            let expr = Expression(expression: block, location: location)
            return contain(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
