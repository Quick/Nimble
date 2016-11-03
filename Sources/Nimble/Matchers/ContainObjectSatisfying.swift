import Foundation

public func containObjectSatisfying<S: Sequence, T>(_ predicate: @escaping ((T) -> Bool), _ predicateDescription: String = "") -> NonNilMatcherFunc<S> where S.Iterator.Element == T {

    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.actualValue = nil

        if predicateDescription == "" {
            failureMessage.to = "to find object in collection that satisfies predicate"
        } else {
            failureMessage.to = "to find object in collection \(predicateDescription)"
        }

        failureMessage.postfixMessage = ""
        if let sequence = try actualExpression.evaluate() {
            for object in sequence {
                if predicate(object) {
                    return true
                }
            }

            return false
        }

        return false
    }
}

#if _runtime(_ObjC)
    extension NMBObjCMatcher {
        public class func containObjectSatisfyingMatcher(_ predicate: @escaping ((NSObject) -> Bool)) -> NMBObjCMatcher {
            return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
                let value = try! actualExpression.evaluate()
                guard let collection = value as? NSArray else {
                    failureMessage.postfixMessage = "containObjectSatisfying must be provided an NSArray"
                    failureMessage.actualValue = nil
                    failureMessage.expected = ""
                    failureMessage.to = ""
                    return false
                }

                for item in collection {
                    guard let object = item as? NSObject else {
                        continue
                    }

                    if predicate(object) {
                        return true
                    }
                }

                failureMessage.actualValue = nil
                failureMessage.postfixMessage = ""
                failureMessage.to = "to find object in collection that satisfies predicate"
                return false
            }
        }
    }
#endif
