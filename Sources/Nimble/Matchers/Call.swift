public func call(_ function: String, withArguments arguments: GloballyEquatable..., countSpecifier: CountSpecifier = .atLeast(1)) -> NonNilMatcherFunc<CallRecorder> {
    return NonNilMatcherFunc { expression, failureMessage in
        guard let expressionValue = try expression.evaluate() else {
            failureMessage.postfixMessage = postfixMessageForNilCase(arguments: arguments, countSpecifier: countSpecifier)
            failureMessage.postfixActual = " (use beNil() to match nils)"
            return false
        }

        let result = expressionValue.didCall(function: function, withArguments: arguments, countSpecifier: countSpecifier)

        failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: arguments, countSpecifier: countSpecifier)
        failureMessage.actualValue = result.recordedCallsDescription

        return result.success
    }
}

// MARK: Private

private func descriptionOfAttemptedCall(object: CallRecorder, function: String, arguments: [GloballyEquatable], countSpecifier: CountSpecifier) -> String {
    var description = "call <\(function)> from \(type(of: object))"

    if !arguments.isEmpty {
        let argumentsDescription = arguments.map{ "\($0)" }.joined(separator: ", ")
        description += " with \(argumentsDescription)"
    }

    let countDescription: String
    let count: Int
    switch countSpecifier {
    case .exactly(let _count):
        countDescription = "exactly"
        count = _count
    case .atLeast(let _count) where _count != 1:
        countDescription = "at least"
        count = _count
    case .atMost(let _count):
        countDescription = "at most"
        count = _count
    default:
        countDescription = ""
        count = -1
    }

    if !countDescription.isEmpty {
        let pluralism = count == 1 ? "" : "s"
        description += " \(countDescription) \(count) time\(pluralism)"
    }

    return description
}

private func postfixMessageForNilCase(arguments: [GloballyEquatable], countSpecifier: CountSpecifier) -> String {
    var postfixMessage = "call function"

    if arguments.count != 0 {
        postfixMessage += " with arguments"
    }

    switch countSpecifier {
    case .exactly(_):
        postfixMessage += " count times"
    case .atLeast(let count) where count != 1:
        postfixMessage += " at least count times"
    case .atMost(_):
        postfixMessage += " at most count times"
    default: break
    }

    return postfixMessage
}
