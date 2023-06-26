/// Allows you to temporarily replace the current Nimble assertion handler with
/// the one provided for the scope of the closure.
///
/// Once the closure finishes, then the original Nimble assertion handler is restored.
///
/// @warning
/// Unlike the synchronous version of this call, this does not support catching Objective-C exceptions.
///
/// @see AssertionHandler
public func withAssertionHandler(_ tempAssertionHandler: AssertionHandler,
                                 file: FileString = #file,
                                 line: UInt = #line,
                                 closure: () async throws -> Void) async {
    let environment = NimbleEnvironment.activeInstance
    let oldRecorder = environment.assertionHandler
    _ = NMBExceptionCapture(handler: nil, finally: ({
        environment.assertionHandler = oldRecorder
    }))
    environment.assertionHandler = tempAssertionHandler

    do {
        try await closure()
    } catch {
        let failureMessage = FailureMessage()
        failureMessage.stringValue = "unexpected error thrown: <\(error)>"
        let location = SourceLocation(file: file, line: line)
        tempAssertionHandler.assert(false, message: failureMessage, location: location)
    }
}

/// Captures expectations that occur in the given closure. Note that all
/// expectations will still go through to the default Nimble handler.
///
/// This can be useful if you want to gather information about expectations
/// that occur within a closure.
///
/// @warning
/// Unlike the synchronous version of this call, this does not support catching Objective-C exceptions.
///
/// @param silently expectations are no longer send to the default Nimble
///                 assertion handler when this is true. Defaults to false.
///
/// @see gatherFailingExpectations
public func gatherExpectations(silently: Bool = false, closure: () async -> Void) async -> [AssertionRecord] {
    let previousRecorder = NimbleEnvironment.activeInstance.assertionHandler
    let recorder = AssertionRecorder()
    let handlers: [AssertionHandler]

    if silently {
        handlers = [recorder]
    } else {
        handlers = [recorder, previousRecorder]
    }

    let dispatcher = AssertionDispatcher(handlers: handlers)
    await withAssertionHandler(dispatcher, closure: closure)
    return recorder.assertions
}

/// Captures failed expectations that occur in the given closure. Note that all
/// expectations will still go through to the default Nimble handler.
///
/// This can be useful if you want to gather information about failed
/// expectations that occur within a closure.
///
/// @warning
/// Unlike the synchronous version of this call, this does not support catching Objective-C exceptions.
///
/// @param silently expectations are no longer send to the default Nimble
///                 assertion handler when this is true. Defaults to false.
///
/// @see gatherExpectations
/// @see raiseException source for an example use case.
public func gatherFailingExpectations(silently: Bool = false, closure: () async -> Void) async -> [AssertionRecord] {
    let assertions = await gatherExpectations(silently: silently, closure: closure)
    return assertions.filter { assertion in
        !assertion.success
    }
}
