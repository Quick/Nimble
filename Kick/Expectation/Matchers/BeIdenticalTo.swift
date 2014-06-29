import Foundation

func _identityAsString(value: NSObject?) -> String {
    if !value {
        return "nil"
    }
    var str: String
    let args = VaListBuilder()
    args.append(value!.description)
    args.append(value!)
    str = NSString(format: "<%@> (0x%p)", arguments: args.va_list())
    return str
}

func beIdenticalTo<T: NSObject>(expected: T?) -> MatcherFunc<T?> {
    return MatcherFunc { actualExpression, failureMessage in
        let actual = actualExpression.evaluate()
        failureMessage.actualValue = "\(_identityAsString(actual))"
        failureMessage.postfixMessage = "be identical to \(_identityAsString(expected))"
        return actual === expected
    }
}

func ===<T: NSObject>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.to(beIdenticalTo(rhs))
    return true
}
func !==<T: NSObject>(lhs: Expectation<T?>, rhs: T?) -> Bool {
    lhs.toNot(beIdenticalTo(rhs))
    return true
}

