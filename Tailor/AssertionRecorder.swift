import Foundation

struct AssertionRecord {
    let success: Bool
    let message: String
    let file: String
    let line: Int
}

class AssertionRecorder : AssertionHandler {
    var assertions = AssertionRecord[]()

    func assert(assertion: Bool, message: String, file: String, line: Int) {
        assertions.append(
            AssertionRecord(
                success: assertion,
                message: message,
                file: file,
                line: line))
    }

    func fail(message: String, file: String, line: Int)  {
        assert(false, message: message, file: file, line: line)
    }
}
