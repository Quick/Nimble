import Foundation

/// Encapsulates the failure message that matchers can report to the end user.
///
/// This is shared state between Nimble and matchers that mutate this value.
public final class FailureMessage: NSObject, @unchecked Sendable {
    private let lock = NSRecursiveLock()

    private var _expected: String = "expected"
    private var _actualValue: String? = "" // empty string -> use default; nil -> exclude
    private var _to: String = "to"
    private var _postfixMessage: String = "match"
    private var _postfixActual: String = ""
    /// An optional message that will be appended as a new line and provides additional details
    /// about the failure. This message will only be visible in the issue navigator / in logs but
    /// not directly in the source editor since only a single line is presented there.
    private var _extendedMessage: String?
    private var _userDescription: String?

    public var expected: String {
        get {
            return lock.sync { return _expected }
        }
        set {
            lock.sync { _expected = newValue }
        }
    }
    public var actualValue: String? {
        get {
            return lock.sync { return _actualValue }
        }
        set {
            lock.sync { _actualValue = newValue }
        }
    } // empty string -> use default; nil -> exclude
    public var to: String {
        get {
            return lock.sync { return _to }
        }
        set {
            lock.sync { _to = newValue }
        }
    }
    public var postfixMessage: String {
        get {
            return lock.sync { return _postfixMessage }
        }
        set {
            lock.sync { _postfixMessage = newValue }
        }
    }
    public var postfixActual: String {
        get {
            return lock.sync { return _postfixActual }
        }
        set {
            lock.sync { _postfixActual = newValue }
        }
    }
    /// An optional message that will be appended as a new line and provides additional details
    /// about the failure. This message will only be visible in the issue navigator / in logs but
    /// not directly in the source editor since only a single line is presented there.
    public var extendedMessage: String? {
        get {
            return lock.sync { return _extendedMessage }
        }
        set {
            lock.sync { _extendedMessage = newValue }
        }
    }
    public var userDescription: String? {
        get {
            return lock.sync { return _userDescription }
        }
        set {
            lock.sync { _userDescription = newValue }
        }
    }

    private var _stringValue: String {
        get {
            if let value = _stringValueOverride {
                return value
            } else {
                return computeStringValue()
            }
        }
        set {
            _stringValueOverride = newValue
        }
    }
    public var stringValue: String {
        get {
            return lock.sync { return _stringValue }
        }
        set {
            lock.sync { _stringValue = newValue }
        }
    }

    private var _stringValueOverride: String?
    private var _hasOverriddenStringValue: Bool {
        return _stringValueOverride != nil
    }

    internal var hasOverriddenStringValue: Bool {
        return lock.sync { return _hasOverriddenStringValue }
    }

    public override init() {
        super.init()
    }

    public init(stringValue: String) {
        _stringValueOverride = stringValue
    }

    private func stripNewlines(_ str: String) -> String {
        let whitespaces = CharacterSet.whitespacesAndNewlines
        return str
            .components(separatedBy: "\n")
            .map { line in line.trimmingCharacters(in: whitespaces) }
            .joined(separator: "")
    }

    private func computeStringValue() -> String {
        return lock.sync {
            var value = "\(_expected) \(_to) \(_postfixMessage)"
            if let actualValue = _actualValue {
                value = "\(_expected) \(_to) \(_postfixMessage), got \(actualValue)\(_postfixActual)"
            }
            value = stripNewlines(value)

            if let extendedMessage = _extendedMessage {
                value += "\n\(extendedMessage)"
            }

            if let userDescription = _userDescription {
                return "\(userDescription)\n\(value)"
            }

            return value
        }
    }

    internal func appendMessage(_ msg: String) {
        lock.sync {
            if _hasOverriddenStringValue {
                _stringValue += "\(msg)"
            } else if _actualValue != nil {
                _postfixActual += msg
            } else {
                _postfixMessage += msg
            }
        }
    }

    internal func appendDetails(_ msg: String) {
        lock.sync {
            if _hasOverriddenStringValue {
                if let desc = _userDescription {
                    _stringValue = "\(desc)\n\(_stringValue)"
                }
                _stringValue += "\n\(msg)"
            } else {
                if let desc = _userDescription {
                    _userDescription = desc
                }
                _extendedMessage = msg
            }
        }
    }

    internal func toExpectationMessage() -> ExpectationMessage {
        lock.sync {
            let defaultMessage = FailureMessage()
            if _expected != defaultMessage._expected || _hasOverriddenStringValue {
                return .fail(_stringValue)
            }

            var message: ExpectationMessage = .fail(_userDescription ?? "")
            if _actualValue != "" && _actualValue != nil {
                message = .expectedCustomValueTo(_postfixMessage, actual: _actualValue ?? "")
            } else if _postfixMessage != defaultMessage._postfixMessage {
                if _actualValue == nil {
                    message = .expectedTo(_postfixMessage)
                } else {
                    message = .expectedActualValueTo(_postfixMessage)
                }
            }
            if _postfixActual != defaultMessage._postfixActual {
                message = .appends(message, _postfixActual)
            }
            if let extended = _extendedMessage {
                message = .details(message, extended)
            }
            return message
        }
    }
}
