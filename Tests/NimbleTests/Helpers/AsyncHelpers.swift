import Nimble

func asyncEqual<T: Equatable>(_ expectedValue: T) -> AsyncPredicate<T> {
    AsyncPredicate.define { expression in
        let message = ExpectationMessage.expectedActualValueTo("equal \(expectedValue)")
        if let value = try await expression.evaluate() {
            return PredicateResult(bool: value == expectedValue, message: message)
        } else {
            return PredicateResult(status: .fail, message: message.appendedBeNilHint())
        }
    }
}

func asyncContain<S: Sequence>(_ items: S.Element...) -> AsyncPredicate<S> where S.Element: Equatable {
    return asyncContain(items)
}

func asyncContain<S: Sequence>(_ items: [S.Element]) -> AsyncPredicate<S> where S.Element: Equatable {
    return AsyncPredicate.simple("contain <\(String(describing: items))>") { actualExpression in
        guard let actual = try await actualExpression.evaluate() else { return .fail }

        let matches = items.allSatisfy {
            return actual.contains($0)
        }
        return PredicateStatus(bool: matches)
    }
}

func asyncEqualityCheck<T: Equatable>(_ received: T, _ expected: T) async -> Bool {
    received == expected
}
