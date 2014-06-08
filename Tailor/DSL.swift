import Foundation

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(expression: @auto_closure () -> T, file: String = __FILE__, line: Int = __LINE__) -> Expectation<T> {
    return Expectation(closure: expression, file: file, line: line)
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(expression: @auto_closure () -> Void, file: String = __FILE__, line: Int = __LINE__) -> Expectation<Bool> {
    return Expectation(closure: ({ expression(); return false }), file: file, line: line)
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(file: String = __FILE__, line: Int = __LINE__, expression: () -> T) -> Expectation<T> {
    return Expectation(closure: expression, file: file, line: line)
}

// Begins an assertion on a given value.
// file: and line: can be omitted to default to the current line this function is called on.
func expect<T>(file: String = __FILE__, line: Int = __LINE__, expression: () -> Void) -> Expectation<Bool> {
    return Expectation(closure: ({ expression(); return false }), file: file, line: line)
}

