import Foundation

class FailureMessage {
    var expected: String = "expected"
    var actualValue: String? = "" // empty string -> use default; nil -> exclude
    var to: String = "to"
    var postfixMessage: String = "match"

    init() {
    }

    func stringValue() -> String {
        if actualValue {
            return "\(expected) \(actualValue) \(to) \(postfixMessage)"
        } else {
            return "\(expected) \(to) \(postfixMessage)"
        }
    }
}