import Foundation

protocol AssertionHandler {
    func assert(assertion: Bool, message: String, file: String, line: Int)
    func fail(message: String, file: String, line: Int)
}

var CurrentAssertionHandler: AssertionHandler = XCTestHandler()

func withAssertionHandler(recorder: AssertionHandler, closure: () -> Void) {
    let oldRecorder = CurrentAssertionHandler
    let capturer = TSExceptionCapture(handler: nil, finally: ({
        CurrentAssertionHandler = oldRecorder
        }))
    capturer.tryBlock {
        CurrentAssertionHandler = recorder
        closure()
    }
}
