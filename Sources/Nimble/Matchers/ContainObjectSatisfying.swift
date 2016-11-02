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
