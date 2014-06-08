import Foundation

func fail(message: String, file: String = __FILE__, line: Int = __LINE__) {
    CurrentAssertionHandler.assert(false, message: message, file: file, line: line)
}

func fail(file: String = __FILE__, line: Int = __LINE__) {
    fail("Failed", file: file, line: line)
}
