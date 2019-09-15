import Dispatch
import Foundation

public enum PosixSignal {
    /// Execute block catching signals with handler
    /// - Parameter handler: A closure can catch signal
    /// - Parameter block: A closure can produce signal
    public static func `do`(_ block: () -> Void, catch handler: @escaping XCTAssertCrashSignalHandler) {
        registerHandlers()
        defer { unregisterHandlers() }

        Thread.current.registerSignalHandler(handler)
        defer { Thread.current.unregisterSignalHandler() }

        SwiftReportFatalErrorsToDebugger.disable()
        defer { SwiftReportFatalErrorsToDebugger.restore() }

        block()
    }
}

// swiftlint:disable identifier_name

private extension PosixSignal {
    // MARK: - Register POSIX Signal Handlers

    static let targetSignals: [Int32] = [SIGILL, SIGABRT, SIGBUS, SIGSEGV]

    struct SignalInfo {
        var oldAction = sigaction()
        var signal: Int32
        init(_ signal: Int32) {
            self.signal = signal
        }
    }

    static var registeredSignalInfo = [SignalInfo]()
    static let queue = DispatchQueue(label: "XCTAssertCrash.registerHandlers()")

    static func registerHandlers() {
        queue.sync {
            // If the handlers are already registered, we're done.
            guard registeredSignalInfo.isEmpty else { return }

            // Create an alternate stack for signal handling. This is necessary for us to
            // be able to reliably handle signals due to stack overflow.
            stack_t.setupAltStack

            (targetSignals).forEach { signal in
                let sa_flags = Int32(SA_NODEFER) | Int32(bitPattern: UInt32(SA_RESETHAND)) | Int32(SA_ONSTACK)
                var newAction = sigaction(callSignalHandler, sa_flags)
                var signalInfo = SignalInfo(signal)
                // Install the new handler, save the old one in RegisteredSignalInfo.
                sigaction(signal, &newAction, &signalInfo.oldAction)
                registeredSignalInfo.append(signalInfo)
            }
        }
    }

    static func unregisterHandlers() {
        queue.sync {
            // Restore all of the signal handlers to how they were before we showed up.
            registeredSignalInfo.forEach { signalInfo in
                var signalInfo = signalInfo
                sigaction(signalInfo.signal, &signalInfo.oldAction, nil)
            }
            registeredSignalInfo.removeAll(keepingCapacity: true)
        }
    }
}

private func callSignalHandler(signal: Int32) {
    PosixSignal.unregisterHandlers()

    // Unmask all potentially blocked kill signals.
    var sigMask = sigset_t()
    sigfillset(&sigMask)
    pthread_sigmask(SIG_UNBLOCK, &sigMask, nil)

    if let signalHandler = Thread.current.unregisterSignalHandler() {
    #if canImport(Darwin)
        SwiftReportFatalErrorsToDebugger.restore()
    #endif
        signalHandler(signal)
        Thread.sleep(forTimeInterval: .greatestFiniteMagnitude)
    } else {
        raise(signal)   // Execute the default handler.
    }
}

// MARK: - Extensions

// MARK: sigaction

private extension sigaction {
    init(_ action: @escaping @convention(c) (Int32) -> Void, _ sa_flags: Int32 = 0) {
    #if canImport(Darwin)
        self.init()
        self.__sigaction_u.__sa_handler = action
    #elseif os(Linux)
        self.init()
        self.__sigaction_handler.sa_handler = action
    #else
        self.init()
        #warning("unsupported platform")
    #endif
    }
}

// MARK: stack_t

private extension stack_t {
    static let setupAltStack: Void = {
    #if !os(tvOS) && !os(watchOS)
        createAltStack()
    #endif
    }()

#if !os(tvOS) && !os(watchOS)
    private static func createAltStack() {
        let altStackSize = MINSIGSTKSZ + 64 * 1024
        var oldStack = stack_t()

        guard sigaltstack(nil, &oldStack) == 0 &&
            oldStack.ss_flags & numericCast(SS_ONSTACK) == 0 && // Thread is not currently executing on oldAltStack
            !(oldStack.ss_sp != nil && oldStack.ss_size > altStackSize) // oldAltStack does not have sufficient size
            else { return }

        var altStack = stack_t.allocate(size: numericCast(altStackSize))
        if sigaltstack(&altStack, &oldStack) != 0 {
            altStack.deallocate()
        }
    }
#endif

    private static func allocate(size: Int) -> stack_t {
        var stack = stack_t()
        stack.ss_sp = UnsafeMutableRawPointer.allocate(byteCount: numericCast(size), alignment: 1)
        stack.ss_size = numericCast(size)
        return stack
    }

    private func deallocate() {
        ss_sp.deallocate()
    }
}
