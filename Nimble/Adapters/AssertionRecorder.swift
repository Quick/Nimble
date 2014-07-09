import Foundation

struct AssertionRecord {
    let success: Bool
    let message: String
    let location: SourceLocation
}

class AssertionRecorder : AssertionHandler {
    var assertions = [AssertionRecord]()

    func assert(assertion: Bool, message: String, location: SourceLocation) {
        assertions.append(
            AssertionRecord(
                success: assertion,
                message: message,
                location: location))
    }
}

func withAssertionHandler(recorder: AssertionHandler, closure: () -> Void) {
    let oldRecorder = CurrentAssertionHandler
    let capturer = NMBExceptionCapture(handler: nil, finally: ({
        CurrentAssertionHandler = oldRecorder
    }))
    CurrentAssertionHandler = recorder
    capturer.tryBlock {
        closure()
    }
}
