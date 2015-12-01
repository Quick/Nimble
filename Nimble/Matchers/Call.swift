import Foundation

public func call(function function: String) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            return false
        }
        
        let result = expressionValue.didCall(function: function, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        if !result.success {
            failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: [], countDescription: "", count: 0)
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return result.success
    }
}

public func call(function function: String, count: Int) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            return false
        }
        
        let result = expressionValue.didCall(function: function, count: count, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        if !result.success {
            failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: [], countDescription: "exactly", count: count)
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return result.success
    }
}

public func call(function function: String, atLeast: Int) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            return false
        }
        
        let result = expressionValue.didCall(function: function, atLeast: atLeast, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        if !result.success {
            failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: [], countDescription: "at least", count: atLeast)
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return result.success
    }
}

public func call(function function: String, atMost: Int) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            return false
        }
        
        let result = expressionValue.didCall(function: function, atMost: atMost, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        if !result.success {
            failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: [], countDescription: "at most", count: atMost)
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return result.success
    }
}

public func call(function function: String, withArguments arguments: [Any]) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            return false
        }
        
        let result = expressionValue.didCall(function: function, withArgs: arguments, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        if !result.success {
            failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: arguments, countDescription: "", count: 0)
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return result.success
    }
}

// MARK: Private

private func descriptionOfAttemptedCall(object object: Any, function: String, arguments: [Any], countDescription: String, count: Int) -> String {
    var description = "call <\(function)> from \(object.dynamicType)"
    if !arguments.isEmpty {
        description += " with \(arguments.map{ "\($0)" }.joinWithSeparator(", "))"
    } else if !countDescription.isEmpty {
        let pluralism = count == 1 ? "" : "s"
        description += " \(countDescription) \(count) time\(pluralism)"
    }
    
    return description
}
