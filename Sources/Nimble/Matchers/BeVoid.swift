/// A Nimble matcher that succeeds when the actual value is Void.
public func beVoid() -> Matcher<()> {
    return Matcher.simpleNilable("be void") { actualExpression in
        let actualValue: ()? = try actualExpression.evaluate()
        return MatcherStatus(bool: actualValue != nil)
    }
}

public func == (lhs: SyncExpectation<()>, rhs: ()) {
    lhs.to(beVoid())
}

public func == (lhs: AsyncExpectation<()>, rhs: ()) async {
    await lhs.to(beVoid())
}

public func != (lhs: SyncExpectation<()>, rhs: ()) {
    lhs.toNot(beVoid())
}

public func != (lhs: AsyncExpectation<()>, rhs: ()) async {
    await lhs.toNot(beVoid())
}
