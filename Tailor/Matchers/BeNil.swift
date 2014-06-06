import Foundation

struct _BeNil: Matcher {
    func matches(actualExpression: () -> Any?) -> (pass: Bool, messagePostfix: String)  {
        let actualValue = actualExpression()
        return (!actualValue.getLogicValue(), "be nil")
    }
}

func beNil() -> PartialMatcher<Any?, _BeNil> {
    return PartialMatcher(matcher: _BeNil())
}
