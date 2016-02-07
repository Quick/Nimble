import Foundation

public func call(function function: String, withArguments arguments: [Any] = [Any](), countSpecifier: CountSpecifier = .AtLeast(1)) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            failureMessage.postfixMessage = postfixMessageForNilCase(arguments: arguments, countSpecifier: countSpecifier)
            failureMessage.postfixActual = " (use beNil() to match nils)"
            return false
        }
        
        let includeOption = didCallResultIncludeOptionFor(isNegationTest: isNegationTest)
        let result = expressionValue.didCall(function: function, withArguments: arguments, countSpecifier: countSpecifier, recordedCallsDescOption: includeOption)
        let successfulTest = isSuccessfulTest(result.success, isNegationTest)
        
        if !successfulTest {
            failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: arguments, countSpecifier: countSpecifier)
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return successfulTest
    }
}

// MARK: Private

private func descriptionOfAttemptedCall(object object: Any, function: String, arguments: [Any], countSpecifier: CountSpecifier) -> String {
    var description = "call <\(function)> from \(object.dynamicType)"
    
    if !arguments.isEmpty {
        let argumentsDescription = arguments.map{ "\($0)" }.joinWithSeparator(", ")
        description += " with \(argumentsDescription)"
    }
    
    let countDescription: String
    let count: Int
    switch countSpecifier {
        case .Exactly(let _count):
            countDescription = "exactly"
            count = _count
        case .AtLeast(let _count) where _count != 1:
            countDescription = "at least"
            count = _count
        case .AtMost(let _count):
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

private func postfixMessageForNilCase(arguments arguments: [Any], countSpecifier: CountSpecifier) -> String {
    var postfixMessage = "call function"
    
    if arguments.count != 0 {
        postfixMessage += " with arguments"
    }
    
    switch countSpecifier {
        case .Exactly(_):
            postfixMessage += " count times"
        case .AtLeast(let count) where count != 1:
            postfixMessage += " at least count times"
        case .AtMost(_):
            postfixMessage += " at most count times"
        default: break
    }
    
    return postfixMessage
}

private func isSuccessfulTest(didDoIt: Bool, _ isNegationTest: Bool) -> Bool {
    return didDoIt != isNegationTest
}

private func didCallResultIncludeOptionFor(isNegationTest isNegationTest: Bool) -> DidCallResultIncludeOption {
    return isNegationTest ? .OnlyOnSuccess : .OnlyOnUnsuccess
}
