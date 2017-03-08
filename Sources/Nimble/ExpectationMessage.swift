// TODO: rename all methods to swift immutable style (-ing)
public indirect enum ExpectationMessage {
    /// includes actual value in output ("expected to <string>, got <actual>")
    case expectedValueTo(/* message: */ String, /* actual: */ String)
    /// includes actual value in output ("expected to <string>, got <actual>")
    case expectedActualValueTo(/* message: */ String)
    /// excludes actual value in output ("expected to <string>")
    case expectedTo(/* message: */ String)
    /// allows any free-form message ("<string>")
    case fail(/* message: */ String)

    /// appends after an existing message ("<expectation> (use beNil() to match nils)")
    case appends(ExpectationMessage, /* Appended Message */ String)

    /// provides long-form multi-line explainations ("<expectation>\n\n<string>")
    case details(ExpectationMessage, String)

    internal var sampleMessage: String {
        let asStr = toString(actual: "<ACTUAL>", expected: "expected", to: "to")
        let asFailureMessage = FailureMessage()
        update(failureMessage: asFailureMessage)
        return "(toString(actual:expected:to:) -> \(asStr) || update(failureMessage:) -> \(asFailureMessage.stringValue))"
    }

    internal var message: String? {
        switch self {
        case let .expectedValueTo(msg, _):
            return msg
        case let .expectedTo(msg):
            return msg
        case let .expectedActualValueTo(msg):
            return msg
        case let .fail(msg):
            return msg
        default:
            return nil
        }
    }

    internal func append(message: String) -> ExpectationMessage {
        switch self {
        case .fail, .expectedTo, .expectedActualValueTo, .expectedValueTo, .appends:
            return .appends(self, message)
        case .details:
            return visit { $0.append(message: message) }
        }
    }

    internal func appendBeNilHint() -> ExpectationMessage {
        return append(message: " (use beNil() to match nils)")
    }

    internal func append(details: String) -> ExpectationMessage {
        return .details(self, details)
    }

    internal func visit(_ f: (ExpectationMessage) -> ExpectationMessage) -> ExpectationMessage {
        switch self {
        case .fail, .expectedTo, .expectedActualValueTo, .expectedValueTo:
            return f(self)
        case let .appends(expectation, msg):
            return f(.appends(expectation, msg))
        case let .details(expectation, msg):
            return f(.details(expectation, msg))
        }
    }

    internal func visitLeafs(_ f: (ExpectationMessage) -> ExpectationMessage) -> ExpectationMessage {
        switch self {
        case .fail, .expectedTo, .expectedActualValueTo, .expectedValueTo:
            return f(self)
        case let .appends(expectation, msg):
            return .appends(expectation.visitLeafs(f), msg)
        case let .details(expectation, msg):
            return .details(expectation.visitLeafs(f), msg)
        }
    }

    internal func replaceExpectation(_ f: @escaping (ExpectationMessage) -> ExpectationMessage) -> ExpectationMessage {
        func walk(_ msg: ExpectationMessage) -> ExpectationMessage {
            switch msg {
            case .fail, .expectedTo, .expectedActualValueTo, .expectedValueTo:
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
            case let .expectedTo(msg):
                return .expectedTo(message + msg)
            case let .expectedActualValueTo(msg):
                return .expectedActualValueTo(message + msg)
            case let .expectedValueTo(msg, actual):
                return .expectedValueTo(message + msg, actual)
            default:
                return msg.visitLeafs(walk)
            }
        }
        return visitLeafs(walk)
    }

    internal func toString(actual: String, expected: String = "expected", to: String = "to") -> String {
        switch self {
        case let .fail(msg):
            return msg
        case let .expectedTo(msg):
            return "\(expected) \(to) \(msg)"
        case let .expectedActualValueTo(msg):
            return "\(expected) \(to) \(msg), got \(actual)"
        case let .expectedValueTo(msg, actual):
            return "\(expected) \(to) \(msg), got \(actual)"
        case let .appends(expectation, msg):
            return "\(expectation.toString(actual: actual, expected: expected, to: to))\(msg)"
        case let .details(expectation, msg):
            return "\(expectation.toString(actual: actual, expected: expected, to: to))\n\n\(msg)"
        }
    }

    internal func update(failureMessage: FailureMessage) {
        switch self {
        case let .fail(msg):
            failureMessage.stringValue = msg
        case let .expectedTo(msg):
            failureMessage.actualValue = nil
            failureMessage.postfixMessage = msg
        case let .expectedActualValueTo(msg):
            failureMessage.postfixMessage = msg
        case let .expectedValueTo(msg, actual):
            failureMessage.postfixMessage = msg
            failureMessage.actualValue = actual
        case let .appends(expectation, msg):
            expectation.update(failureMessage: failureMessage)
            if failureMessage.actualValue != nil {
                failureMessage.postfixActual += msg
            } else {
                failureMessage.postfixMessage += msg
            }
        case let .details(expectation, msg):
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
            return .fail(stringValue)
        }

        var msg: ExpectationMessage = .fail(userDescription ?? "")
        if actualValue != "" && actualValue != nil {
            msg = .expectedValueTo(postfixMessage, actualValue ?? "")
        } else if postfixMessage != defaultMsg.postfixMessage {
            if actualValue == nil {
                msg = .expectedTo(postfixMessage)
            } else {
                msg = .expectedActualValueTo(postfixMessage)
            }
        }
        if postfixActual != defaultMsg.postfixActual {
            msg = .appends(msg, postfixActual)
        }
        if let m = extendedMessage {
            msg = .details(msg, m)
        }
        return msg
    }
}
