public indirect enum ExpectationMessage {
    /// includes actual value in output ("expected to <string>, got <actual>")
    case ExpectedValueTo(/* message: */ String, /* actual: */ String)
    /// includes actual value in output ("expected to <string>, got <actual>")
    case ExpectedActualValueTo(/* message: */ String)
    /// excludes actual value in output ("expected to <string>")
    case ExpectedTo(/* message: */ String)
    /// allows any free-form message ("<string>")
    case Fail(/* message: */ String)

    /// appends after an existing message ("<expectation> (use beNil() to match nils)")
    case Append(ExpectationMessage, /* Appended Message */ String)

    /// provides long-form multi-line explainations ("<expectation>\n\n<string>")
    case Details(ExpectationMessage, String)

    internal var sampleMessage: String {
        let asStr = toString(actual: "<ACTUAL>", expected: "expected", to: "to")
        let asFailureMessage = FailureMessage()
        update(failureMessage: asFailureMessage)
        return "(toString(actual:expected:to:) -> \(asStr) || update(failureMessage:) -> \(asFailureMessage.stringValue))"
    }

    internal var message: String? {
        switch self {
        case let .ExpectedValueTo(msg, _):
            return msg
        case let .ExpectedTo(msg):
            return msg
        case let .ExpectedActualValueTo(msg):
            return msg
        case let .Fail(msg):
            return msg
        default:
            return nil
        }
    }

    internal func append(message: String) -> ExpectationMessage {
        switch self {
        case .Fail, .ExpectedTo, .ExpectedActualValueTo, .ExpectedValueTo, .Append:
            return .Append(self, message)
        case .Details:
            return visit { $0.append(message: message) }
        }
    }

    internal func append(details: String) -> ExpectationMessage {
        return .Details(self, details)
    }

    internal func visit(_ f: (ExpectationMessage) -> ExpectationMessage) -> ExpectationMessage {
        switch self {
        case .Fail, .ExpectedTo, .ExpectedActualValueTo, .ExpectedValueTo:
            return f(self)
        case let .Append(expectation, msg):
            return f(.Append(expectation, msg))
        case let .Details(expectation, msg):
            return f(.Details(expectation, msg))
        }
    }

    internal func visitLeafs(_ f: (ExpectationMessage) -> ExpectationMessage) -> ExpectationMessage {
        switch self {
        case .Fail, .ExpectedTo, .ExpectedActualValueTo, .ExpectedValueTo:
            return f(self)
        case let .Append(expectation, msg):
            return .Append(expectation.visitLeafs(f), msg)
        case let .Details(expectation, msg):
            return .Details(expectation.visitLeafs(f), msg)
        }
    }

    internal func replaceExpectation(_ f: @escaping (ExpectationMessage) -> ExpectationMessage) -> ExpectationMessage {
        func walk(_ msg: ExpectationMessage) -> ExpectationMessage {
            switch msg {
            case .Fail, .ExpectedTo, .ExpectedActualValueTo, .ExpectedValueTo:
                return f(msg)
            default:
                return msg
            }
        }
        return visitLeafs(walk)
    }

    internal func wrapExpectation(before: String, after: String) -> ExpectationMessage {
        return prepend(message: before).append(message: after)
    }

    internal func prepend(message: String) -> ExpectationMessage {
        func walk(_ msg: ExpectationMessage) -> ExpectationMessage {
            switch msg {
            case let .ExpectedTo(msg):
                return .ExpectedTo(message + msg)
            case let .ExpectedActualValueTo(msg):
                return .ExpectedActualValueTo(message + msg)
            case let .ExpectedValueTo(msg, actual):
                return .ExpectedValueTo(message + msg, actual)
            default:
                return msg.visitLeafs(walk)
            }
        }
        return visitLeafs(walk)
    }

    internal func toString(actual: String, expected: String = "expected", to: String = "to") -> String {
        switch self {
        case let .Fail(msg):
            return msg
        case let .ExpectedTo(msg):
            return "\(expected) \(to) \(msg)"
        case let .ExpectedActualValueTo(msg):
            return "\(expected) \(to) \(msg), got \(actual)"
        case let .ExpectedValueTo(msg, actual):
            return "\(expected) \(to) \(msg), got \(actual)"
        case let .Append(expectation, msg):
            return "\(expectation.toString(actual: actual, expected: expected, to: to))\(msg)"
        case let .Details(expectation, msg):
            return "\(expectation.toString(actual: actual, expected: expected, to: to))\n\n\(msg)"
        }
    }

    internal func update(failureMessage: FailureMessage) {
        switch self {
        case let .Fail(msg):
            failureMessage.stringValue = msg
        case let .ExpectedTo(msg):
            failureMessage.actualValue = nil
            failureMessage.postfixMessage = msg
        case let .ExpectedActualValueTo(msg):
            failureMessage.postfixMessage = msg
        case let .ExpectedValueTo(msg, actual):
            failureMessage.postfixMessage = msg
            failureMessage.actualValue = actual
        case let .Append(expectation, msg):
            expectation.update(failureMessage: failureMessage)
            if failureMessage.actualValue != nil {
                failureMessage.postfixActual += msg
            } else {
                failureMessage.postfixMessage += msg
            }
        case let .Details(expectation, msg):
            expectation.update(failureMessage: failureMessage)
            if let desc = failureMessage.userDescription {
                failureMessage.userDescription = desc
            }
            failureMessage.extendedMessage = msg
        }
    }
}

extension FailureMessage {
    var toExpectationMessage: ExpectationMessage {
        let defaultMsg = FailureMessage()
        if expected != defaultMsg.expected || _stringValueOverride != nil {
            return .Fail(stringValue)
        }

        var msg: ExpectationMessage = .Fail(userDescription ?? "")
        if actualValue != "" && actualValue != nil {
            msg = .ExpectedValueTo(postfixMessage, actualValue ?? "")
        } else if postfixMessage != defaultMsg.postfixMessage {
            if actualValue == nil {
                msg = .ExpectedTo(postfixMessage)
            } else {
                msg = .ExpectedActualValueTo(postfixMessage)
            }
        }
        if postfixActual != defaultMsg.postfixActual {
            msg = .Append(msg, postfixActual)
        }
        if let m = extendedMessage {
            msg = .Details(msg, m)
        }
        return msg
    }
}
