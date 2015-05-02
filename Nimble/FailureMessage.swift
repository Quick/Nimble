import Foundation

@objc
public class FailureMessage {
    public var expected: String = "expected"
    public var actualValue: String? = "" // empty string -> use default; nil -> exclude
    public var to: String = "to"
    public var postfixMessage: String = "match"
    public var postfixActual: String = ""

    internal var _stringValueOverride: String?

    public init() {
    }

    internal func computeStringValue() -> String {
        var value = "\(expected) \(to) \(postfixMessage)"
        if let actualValue = actualValue {
            value = "\(expected) \(to) \(postfixMessage), got \(actualValue)\(postfixActual)"
        }
        var lines: [String] = (value as NSString).componentsSeparatedByString("\n") as! [String]
        let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        lines = lines.map { line in line.stringByTrimmingCharactersInSet(whitespace) }
        return "".join(lines)
    }

    public var stringValue: String {
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
}