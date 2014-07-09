import Foundation

@objc
class FailureMessage {
    var expected: String = "expected"
    var actualValue: String? = "" // empty string -> use default; nil -> exclude
    var to: String = "to"
    var postfixMessage: String = "match"

    init() {
    }

    func stringValue() -> String {
        var value = "\(expected) \(to) \(postfixMessage)"
        if actualValue {
            value = "\(expected) \(actualValue) \(to) \(postfixMessage)"
        }
        var lines: [String] = (value as NSString).componentsSeparatedByString("\n") as [String]
        let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        lines = lines.map { line in line.stringByTrimmingCharactersInSet(whitespace) }
        return "".join(lines)
    }
}