// swiftlint:disable all
#if canImport(CwlPreconditionTesting) && (os(macOS) || os(iOS) || os(visionOS))
import CwlPreconditionTesting
#elseif canImport(CwlPosixPreconditionTesting)
import CwlPosixPreconditionTesting
#elseif canImport(Glibc)
import Glibc

// This function is called from the signal handler to shut down the thread and return 1 (indicating a SIGILL was received).
private func callThreadExit() {
    pthread_exit(UnsafeMutableRawPointer(bitPattern: 1))
}

// When called, this signal handler simulates a function call to `callThreadExit`
private func sigIllHandler(code: Int32, info: UnsafeMutablePointer<siginfo_t>?, uap: UnsafeMutableRawPointer?) -> Void {
    guard let context = uap?.assumingMemoryBound(to: ucontext_t.self) else { return }

    // 1. Decrement the stack pointer
    context.pointee.uc_mcontext.gregs.15 /* REG_RSP */ -= Int64(MemoryLayout<Int>.size)

    // 2. Save the old Instruction Pointer to the stack.
    let rsp = context.pointee.uc_mcontext.gregs.15 /* REG_RSP */
    if let ump = UnsafeMutablePointer<Int64>(bitPattern: Int(rsp)) {
        ump.pointee = rsp
    }

    // 3. Set the Instruction Pointer to the new function's address
    var f: @convention(c) () -> Void = callThreadExit
    withUnsafePointer(to: &f) {    $0.withMemoryRebound(to: Int64.self, capacity: 1) { ptr in
        context.pointee.uc_mcontext.gregs.16 /* REG_RIP */ = ptr.pointee
    } }
}

/// Without Mach exceptions or the Objective-C runtime, there's nothing to put in the exception object. It's really just a boolean – either a SIGILL was caught or not.
public class BadInstructionException {
}

/// Run the provided block. If a POSIX SIGILL is received, handle it and return a BadInstructionException (which is just an empty object in this POSIX signal version). Otherwise return nil.
/// NOTE: This function is only intended for use in test harnesses – use in a distributed build is almost certainly a bad choice. If a SIGILL is received, the block will be interrupted using a C `longjmp`. The risks associated with abrupt jumps apply here: most Swift functions are *not* interrupt-safe. Memory may be leaked and the program will not necessarily be left in a safe state.
/// - parameter block: a function without parameters that will be run
/// - returns: if an SIGILL is raised during the execution of `block` then a BadInstructionException will be returned, otherwise `nil`.
public func catchBadInstruction(block: @escaping () -> Void) -> BadInstructionException? {
    // Construct the signal action
    var sigActionPrev = sigaction()
    var sigActionNew = sigaction()
    sigemptyset(&sigActionNew.sa_mask)
    sigActionNew.sa_flags = SA_SIGINFO
    sigActionNew.__sigaction_handler = .init(sa_sigaction: sigIllHandler)

    // Install the signal action
    if sigaction(SIGILL, &sigActionNew, &sigActionPrev) != 0 {
        fatalError("Sigaction error: \(errno)")
    }

    defer {
        // Restore the previous signal action
        if sigaction(SIGILL, &sigActionPrev, nil) != 0 {
            fatalError("Sigaction error: \(errno)")
        }
    }

    var b = block
    let caught: Bool = withUnsafeMutablePointer(to: &b) { blockPtr in
        // Run the block on its own thread
        var handlerThread: pthread_t = 0
        let e = pthread_create(&handlerThread, nil, { arg in
            guard let arg = arg else { return nil }
            (arg.assumingMemoryBound(to: (() -> Void).self).pointee)()
            return nil
        }, blockPtr)
        precondition(e == 0, "Unable to create thread")

        // Wait for completion and get the result. It will be either `nil` or bitPattern 1
        var rawResult: UnsafeMutableRawPointer? = nil
        let e2 = pthread_join(handlerThread, &rawResult)
        precondition(e2 == 0, "Thread join failed")
        return Int(bitPattern: rawResult) != 0
    }

    return caught ? BadInstructionException() : nil
}
#endif

public func throwAssertion<Out>() -> Matcher<Out> {
    return Matcher { actualExpression in
    #if (arch(x86_64) || arch(arm64))
        #if (canImport(CwlPreconditionTesting) || canImport(CwlPosixPreconditionTesting) || canImport(Glibc))
        let message = ExpectationMessage.expectedTo("throw an assertion")
        var actualError: Error?
        let caughtException: BadInstructionException? = catchBadInstruction {
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
            #elseif os(watchOS)
            if !NimbleEnvironment.activeInstance.suppressWatchOSAssertionWarning {
                print()
                print("[Nimble Warning]: If you're getting stuck on a debugger breakpoint for a " +
                    "fatal error while using throwAssertion(), please disable 'Debug Executable' " +
                    "in your scheme. Go to 'Edit Scheme > Test > Info' and uncheck " +
                    "'Debug Executable'. If you've already done that, suppress this warning " +
                    "by setting `NimbleEnvironment.activeInstance.suppressWatchOSAssertionWarning = true`. " +
                    "This is required because the standard methods of catching assertions " +
                    "(mach APIs) are unavailable for watchOS. Instead, the same mechanism the " +
                    "debugger uses is the fallback method for watchOS."
                )
                print()
                NimbleEnvironment.activeInstance.suppressWatchOSAssertionWarning = true
            }
            #endif
            do {
                _ = try actualExpression.evaluate()
            } catch {
                actualError = error
            }
        }

        if let actualError = actualError {
            return MatcherResult(
                bool: false,
                message: message.appended(message: "; threw error instead <\(actualError)>")
            )
        } else {
            return MatcherResult(bool: caughtException != nil, message: message)
        }
        #else
        let message = """
            The throwAssertion Nimble matcher does not support your platform.
            Note: throwAssertion no longer works on tvOS or watchOS platforms when you use Nimble with Cocoapods.
                  You will have to use Nimble with Swift Package Manager or Carthage.
            """
        fatalError(message)
        #endif
    #else
        let message = """
            The throwAssertion Nimble matcher can only run on x86_64 and arm64 platforms.
            You can silence this error by placing the test case inside an #if arch(x86_64) || arch(arm64) conditional \
            statement.
            """
        fatalError(message)
    #endif
    }
}
// swiftlint:enable all
