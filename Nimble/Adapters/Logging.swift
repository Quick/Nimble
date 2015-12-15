/// Internal Development Only. Provides Debugging for various files in Nimble.
/// In the future, it may be useful to expose as an async debugging tool.

import Foundation

internal protocol Tracer {
    func trace(
        probeName: String,
        message: String,
        fnName: String,
        fileName: String,
        lineNumber: UInt)
}

internal class StdoutTracer: Tracer {
    func trace(
        probeName: String,
        message: String,
        fnName: String,
        fileName: String,
        lineNumber: UInt) {
            print("[\(NSDate())] \(probeName) \(fnName) \(message)")
    }
}

internal class Probe {
    let name: String
    private var tracers = [Tracer]()

    init(name: String) {
        self.name = name
    }

    func attach(tracer: Tracer) -> Self {
        tracers.append(tracer)
        return self
    }

    func emit(
        @autoclosure message: () -> String,
        fnName: String = __FUNCTION__,
        fileName: String = __FILE__,
        lineNumber: UInt = __LINE__) {
            if !tracers.isEmpty {
                let msg = message()
                for tracer in tracers {
                    tracer.trace(name,
                        message: msg,
                        fnName: fnName,
                        fileName: fileName,
                        lineNumber: lineNumber)
                }
            }
    }

    static let asyncProbe = Probe(name: "Nimble::Async") //.attach(StdoutTracer())
}