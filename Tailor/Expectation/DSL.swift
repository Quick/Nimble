import Foundation

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(expression: @auto_closure () -> T, file: String = __FILE__, line: Int = __LINE__) -> Expectation<T> {
    return Expectation(
        expression: Expression(
            expression: expression,
            location: SourceLocation(file: file, line: line)))
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(file: String = __FILE__, line: Int = __LINE__, expression: () -> T) -> Expectation<T> {
    return Expectation(
        expression: Expression(
            expression: expression,
            location: SourceLocation(file: file, line: line)))
}

func must(assertion: Bool, message: String, #location: SourceLocation) {
    CurrentAssertionHandler.assert(false, message: message, location: location)
}

func must(assertion: Bool, message: String, file: String = __FILE__, line: Int = __LINE__) {
    must(assertion, message, location: SourceLocation(file: file, line: line))
}

func fail(message: String, #location: SourceLocation) {
    must(false, message, location: location)
}

func fail(message: String, file: String = __FILE__, line: Int = __LINE__) {
    fail(message, location: SourceLocation(file: file, line: line))
}

func fail(file: String = __FILE__, line: Int = __LINE__) {
    fail("Failed")
}