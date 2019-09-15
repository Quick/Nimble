import Foundation

#if canImport(XCTAssertCrash)
import XCTAssertCrash
#endif

public func throwAssertion<Out>() -> Predicate<Out> {
    return Predicate { actualExpression in
        let message = ExpectationMessage.expectedTo("throw an assertion")

        var actualError: Error?

        // https://github.com/norio-nomura/XCTAssertCrash/blob/add867b3ec7713fa5eb23bda291f180858f9f5a6/Sources/XCTAssertCrash/XCTAssertCrash.swift#L59-L87
        var signal: Int32 = 0

        #if canImport(Darwin) && !os(tvOS) && !os(watchOS)
        let driver = MachException.do(_:catch:)
        #else
        let driver = PosixSignal.do(_:catch:)
        #endif

        let sema = DispatchSemaphore(value: 0)
        let thread: Thread
        let block: () -> Void = {
            driver({
                #if os(tvOS)
                if !NimbleEnvironment.activeInstance.suppressTVOSAssertionWarning {
                    print()
                    print("[Nimble Warning]: If you're getting stuck on a debugger breakpoint for a " +
                        "fatal error while using throwAssertion(), please disable 'Debug Executable' " +
                        "in your scheme. Go to 'Edit Scheme > Test > Info' and uncheck " +
                        "'Debug Executable'. If you've already done that, suppress this warning " +
                        "by setting `NimbleEnvironment.activeInstance.suppressTVOSAssertionWarning = true`. " +
                        "This is required because the standard methods of catching assertions " +
                        "(mach APIs) are unavailable for tvOS. Instead, the same mechanism the " +
                        "debugger uses is the fallback method for tvOS."
                    )
                    print()
                    NimbleEnvironment.activeInstance.suppressTVOSAssertionWarning = true
                }
                #endif
                do {
                    _ = try actualExpression.evaluate()
                } catch {
                    actualError = error
                }
            }, {
                signal = $0
                sema.signal()
            })
            sema.signal()
        }
        if #available(macOS 12, iOS 10, tvOS 10, watchOS 3, *) {
            thread = Thread(block: block)
        } else {
            thread = _Thread(block: block)
        }
        thread.start()
        sema.wait()

        if let actualError = actualError {
            return PredicateResult(
                bool: false,
                message: message.appended(message: "; threw error instead <\(actualError)>")
            )
        } else {
            return PredicateResult(bool: signal != 0, message: message)
        }
    }
}

private final class _Thread: Thread {
    private let block: () -> Void

    init(block: @escaping () -> Void) {
        self.block = block
    }

    override func main() {
        block()
    }
}
