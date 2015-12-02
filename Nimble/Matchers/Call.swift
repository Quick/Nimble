import Foundation

public func call(function function: String) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            failureMessage.postfixMessage = kCallFunc
            failureMessage.postfixActual = kNilReminderString
            return false
        }
        
        let result = expressionValue.didCall(function: function, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        if !result.success {
            failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: [], countDescription: "", count: 0)
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return isSuccessfulTest(result.success, isNegationTest)
    }
}

public func call(function function: String, count: Int) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            failureMessage.postfixMessage = kCallFunc + kCount
            failureMessage.postfixActual = kNilReminderString
            return false
        }
        
        let result = expressionValue.didCall(function: function, count: count, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        if !result.success {
            failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: [], countDescription: "exactly", count: count)
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return isSuccessfulTest(result.success, isNegationTest)
    }
}

public func call(function function: String, atLeast: Int) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            failureMessage.postfixMessage = kCallFunc + kAtLeast
            failureMessage.postfixActual = kNilReminderString
            return false
        }
        
        let result = expressionValue.didCall(function: function, atLeast: atLeast, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        if !result.success {
            failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: [], countDescription: "at least", count: atLeast)
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return isSuccessfulTest(result.success, isNegationTest)
    }
}

public func call(function function: String, atMost: Int) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            failureMessage.postfixMessage = kCallFunc + kAtMost
            failureMessage.postfixActual = kNilReminderString
            return false
        }
        
        let result = expressionValue.didCall(function: function, atMost: atMost, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        if !result.success {
            failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: [], countDescription: "at most", count: atMost)
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return isSuccessfulTest(result.success, isNegationTest)
    }
}

public func call(function function: String, withArguments arguments: [Any]) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            failureMessage.postfixMessage = kCallFunc + kWithArgs
            failureMessage.postfixActual = kNilReminderString
            return false
        }
        
        let result = expressionValue.didCall(function: function, withArgs: arguments, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        if !result.success {
            failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: arguments, countDescription: "", count: 0)
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return isSuccessfulTest(result.success, isNegationTest)
    }
}

public func call(function function: String, withArguments arguments: [Any], count: Int) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            failureMessage.postfixMessage = kCallFunc + kWithArgs + kCount
            failureMessage.postfixActual = kNilReminderString
            return false
        }
        
        let result = expressionValue.didCall(function: function, withArgs: arguments, count: count, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        if !result.success {
            failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: arguments, countDescription: "exactly", count: count)
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return isSuccessfulTest(result.success, isNegationTest)
    }
}

public func call(function function: String, withArguments arguments: [Any], atLeast: Int) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            failureMessage.postfixMessage = kCallFunc + kWithArgs + kAtLeast
            failureMessage.postfixActual = kNilReminderString
            return false
        }
        
        let result = expressionValue.didCall(function: function, withArgs: arguments, atLeast: atLeast, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        if !result.success {
            failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: arguments, countDescription: "at least", count: atLeast)
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return isSuccessfulTest(result.success, isNegationTest)
    }
}

public func call(function function: String, withArguments arguments: [Any], atMost: Int) -> FullMatcherFunc<CallRecorder> {
    return FullMatcherFunc { expression, failureMessage, isNegationTest in
        guard let expressionValue = try expression.evaluate() else {
            failureMessage.postfixMessage = kCallFunc + kWithArgs + kAtMost
            failureMessage.postfixActual = kNilReminderString
            return false
        }
        
        let result = expressionValue.didCall(function: function, withArgs: arguments, atMost: atMost, recordedCallsDescOption: .OnlyOnUnsuccess)
        
        if !result.success {
            failureMessage.postfixMessage = descriptionOfAttemptedCall(object: expressionValue, function: function, arguments: arguments, countDescription: "at most", count: atMost)
            failureMessage.actualValue = result.recordedCallsDescription
        }
        
        return isSuccessfulTest(result.success, isNegationTest)
    }
}

// MARK: Private

private let kCallFunc = "call function"
private let kWithArgs = " with arguments"
private let kCount = " count times"
private let kAtLeast = " at least count times"
private let kAtMost = " at most count times"
private let kNilReminderString = " (use beNil() to match nils)"

private func descriptionOfAttemptedCall(object object: Any, function: String, arguments: [Any], countDescription: String, count: Int) -> String {
    var description = "call <\(function)> from \(object.dynamicType)"
    
    if !arguments.isEmpty {
        description += " with \(arguments.map{ "\($0)" }.joinWithSeparator(", "))"
    }
    
    if !countDescription.isEmpty {
        let pluralism = count == 1 ? "" : "s"
        description += " \(countDescription) \(count) time\(pluralism)"
    }
    
    return description
}

private func isSuccessfulTest(didDoIt: Bool, _ isNegationTest: Bool) -> Bool {
    return didDoIt && !isNegationTest || !didDoIt && isNegationTest
}
