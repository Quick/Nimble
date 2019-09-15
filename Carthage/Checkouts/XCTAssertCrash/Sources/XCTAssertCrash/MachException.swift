#if canImport(Darwin) && !os(tvOS) && !os(watchOS)

import Dispatch
import Foundation
#if canImport(CMachExceptionHandler)
import CMachExceptionHandler
#endif

public enum MachException {
    /// Execute block catching signals with handler
    /// - Parameter block: A closure can produce signal
    /// - Parameter handler: A closure can catch signal
    public static func `do`(_ block: () -> Void, catch handler: @escaping XCTAssertCrashSignalHandler) {
        Thread.current.registerSignalHandler(handler)
        defer { Thread.current.unregisterSignalHandler() }

        SwiftReportFatalErrorsToDebugger.disable()
        defer { SwiftReportFatalErrorsToDebugger.restore() }

        executeWithExceptionPort(exceptionPort, block)
    }
}

// MARK: - Private

private extension MachException {

    // MARK: C convention function that calls signal handler

    static let callSignalHandlerPointer = {
        unsafeBitCast(callSignalHandler, to: user_addr_t.self)
    }()

    static var callSignalHandler: @convention(c) (Int32) -> Void = { signal in
        SwiftReportFatalErrorsToDebugger.restore()
        if let handler = Thread.current.unregisterSignalHandler() {
            handler(signal)
            Thread.sleep(forTimeInterval: .greatestFiniteMagnitude)
        }
    }

    // MARK: Exception Port

    static let exceptionPort: mach_port_t = startMachExceptionHandlerThread()

    static func installExceptionPort(_ port: mach_port_t, to thread: mach_port_t) {
        let behavior = EXCEPTION_STATE_IDENTITY|exception_behavior_t(bitPattern: MACH_EXCEPTION_CODES)
        kernCheck(thread_set_exception_ports(thread, exceptionMask, port, behavior, threadStateFlavor))
    }

    static func uninstallExceptionPort(from thread: mach_port_t) {
        kernCheck(thread_set_exception_ports(thread, exceptionMask, 0, EXCEPTION_DEFAULT, THREAD_STATE_NONE))
    }

    // MARK: Execute with Setting Exception Port

    static func executeWithExceptionPort(_ port: mach_port_t, _ block: () -> Void) {
        installExceptionPort(port, to: mach_thread_self())
        defer { uninstallExceptionPort(from: mach_thread_self()) }

        block()
    }

    // MARK: Convert Mach Exception to POSIX Signal

    static func ux_exception( // swiftlint:disable:this cyclomatic_complexity
        _ exception: exception_type_t,
        _ code: mach_exception_code_t,
        _ subcode: mach_exception_subcode_t
    ) -> Int32 {
        let machineSignal = machine_exception(exception, code, subcode)
        guard machineSignal == 0 else { return machineSignal }

        switch exception {
        case EXC_BAD_ACCESS:
            return code == KERN_INVALID_ADDRESS ? SIGSEGV : SIGBUS
        case EXC_BAD_INSTRUCTION:
            return SIGILL
        case EXC_ARITHMETIC:
            return SIGFPE
        case EXC_EMULATION:
            return SIGEMT
        case EXC_SOFTWARE:
            switch code {
            // xnu/bsd/sys/ux_exception.h
            case 0x10000: // #define EXC_UNIX_BAD_SYSCALL 0x10000        /* SIGSYS */
                return SIGSYS
            case 0x10001: // #define EXC_UNIX_BAD_PIPE    0x10001        /* SIGPIPE */
                return SIGPIPE
            case 0x10002: // #define EXC_UNIX_ABORT       0x10002        /* SIGABRT */
                return SIGABRT

            // mach/exception_types.h
            case 0x10003: // #define EXC_SOFT_SIGNAL         0x10003 /* Unix signal exceptions */
                return SIGKILL
            default:
                break
            }
        case EXC_BREAKPOINT:
            return SIGTRAP
        default:
            break
        }

        return 0
    }

    static func machine_exception(
        _ exception: exception_type_t,
        _ code: mach_exception_code_t,
        _ subcode: mach_exception_subcode_t
    ) -> Int32 {
    #if arch(x86_64) || arch(i386)
        // xnu/bsd/dev/i386/unix_signal.c
        switch exception {
        case EXC_BAD_ACCESS:
            /* Map GP fault to SIGSEGV, otherwise defer to caller */
            if code == EXC_I386_GPFLT {
                return SIGSEGV
            }
        case EXC_BAD_INSTRUCTION:
            return SIGILL
        case EXC_ARITHMETIC:
            return SIGFPE
        case EXC_SOFTWARE:
            if code == EXC_I386_BOUND {
                /*
                 * Map #BR, the Bound Range Exceeded exception, to
                 * SIGTRAP.
                 */
                return SIGTRAP
            }
        default:
            break
        }
    #elseif arch(arm64) || arch(arm)
        // xnu/bsd/dev/arm/unix_signal.c
        switch exception {
        case EXC_BAD_INSTRUCTION:
            return SIGILL
        case EXC_ARITHMETIC:
            return SIGFPE
        default:
            break
        }
    #endif
        return 0
    }

    // MARK: private

    private static let exceptionMask: exception_mask_t = {
    #if arch(x86_64)
        return exception_mask_t(EXC_MASK_BAD_ACCESS|EXC_MASK_BAD_INSTRUCTION)
    #elseif arch(arm64)
        return exception_mask_t(EXC_MASK_BAD_ACCESS|EXC_MASK_BAD_INSTRUCTION|EXC_MASK_BREAKPOINT)
    #else
        #error("Unsupported Architecture")
    #endif
    }()

    private static let threadStateFlavor: thread_state_flavor_t = {
    #if arch(x86_64)
        return x86_thread_state64_t.flavor
    #elseif arch(arm64)
        // Use `ARM_DEBUG_STATE64` instead of `ARM_THREAD_STATE64`.
        // See comment in `catch_mach_exception_raise_state_identity`.
        return arm_debug_state64_t.flavor
    #else
        #error("Unsupported Architecture")
    #endif
    }()
}

// MARK: - Internal functions for `mach_excServer.c`

// swiftlint:disable identifier_name

@_cdecl("catch_mach_exception_raise_state_identity")
func catch_mach_exception_raise_state_identity( // swiftlint:disable:this function_parameter_count
    _ exception_port: mach_port_t,
    _ thread: mach_port_t,
    _ task: mach_port_t,
    _ exception: exception_type_t,
    _ code: mach_exception_data_t!,
    _ codeCnt: mach_msg_type_number_t,
    _ flavor: UnsafeMutablePointer<Int32>!,
    _ old_state: thread_state_t!,
    _ old_stateCnt: mach_msg_type_number_t,
    _ new_state: thread_state_t!,
    _ new_stateCnt: UnsafeMutablePointer<mach_msg_type_number_t>!
) -> kern_return_t {
    // POSIX Signal
    let signal = MachException.ux_exception(exception, code[0], code[1])

#if arch(x86_64)

    guard flavor.pointee == x86_thread_state64_t.flavor,
        min(old_stateCnt, new_stateCnt.pointee) >= x86_thread_state64_t.count else {
            return KERN_INVALID_ARGUMENT
    }

    // Start modifying thread state
    var thread_state = old_state.x86_thread_state64

    // 1. Decrement the stack pointer
    thread_state.__rsp -= numericCast(MemoryLayout<register_t>.size)

    // 2. Save the old Instruction Pointer to the stack.
    if let pointer = UnsafeMutablePointer<__uint64_t>(bitPattern: UInt(thread_state.__rsp)) {
        pointer.pointee = thread_state.__rip
    } else {
        return KERN_INVALID_ARGUMENT
    }

    // 3. Change the Instruction Pointer to the new function's address
    thread_state.__rip = MachException.callSignalHandlerPointer

    // 4. Set signal to parameter
    thread_state.__rdi = numericCast(signal)

    // Return new state
    new_state.x86_thread_state64 = thread_state
    new_stateCnt.pointee = x86_thread_state64_t.count

#elseif arch(arm64)

    // Use `ARM_DEBUG_STATE64` for resetting return `EXC_BREAKPOINT`
    guard flavor.pointee == arm_debug_state64_t.flavor,
        min(old_stateCnt, new_stateCnt.pointee) >= arm_debug_state64_t.count else {
            return KERN_INVALID_ARGUMENT
    }

    MachException.uninstallExceptionPort(from: mach_thread_self())

    // Get thread state
    var thread_state = arm_thread_state64_t(from: thread)

    if exception == EXC_BREAKPOINT && !thread_state.isProgramCounterPointingBRK {
        // Won't change state
        assertionFailure("""
            `XCTAssertCrash` detects a stop at a breakpoint set by the debugger and \
            can not support to handle the breakpoint set in expression.
            """)
    }

    // Change thread state to call `callSignalHandlerPointer`
    thread_state.__pc = MachException.callSignalHandlerPointer // Change program counter
    thread_state.__x.0 = __uint64_t(signal) // Pass `signal` as a parameter
    thread_state.set(to: thread)

    // Change debug state to disable Hardware Single Step
    var debug_state = old_state.arm_debug_state64
    debug_state.__mdscr_el1 &= ~1
    new_state.arm_debug_state64 = debug_state
    new_stateCnt.pointee = arm_debug_state64_t.count

#else
    #warning("unsupported Architecture")
#endif

    return KERN_SUCCESS
}

@_cdecl("catch_mach_exception_raise_state")
func catch_mach_exception_raise_state( // swiftlint:disable:this function_parameter_count
    _ exception_port: mach_port_t,
    _ exception: exception_type_t,
    _ code: mach_exception_data_t!,
    _ codeCnt: mach_msg_type_number_t,
    _ flavor: UnsafeMutablePointer<Int32>!,
    _ old_state: thread_state_t!,
    _ old_stateCnt: mach_msg_type_number_t,
    _ new_state: thread_state_t!,
    _ new_stateCnt: UnsafeMutablePointer<mach_msg_type_number_t>!
) -> kern_return_t {
    preconditionFailure()
}

@_cdecl("catch_mach_exception_raise")
func catch_mach_exception_raise( // swiftlint:disable:this function_parameter_count
    _ exception_port: mach_port_t,
    _ thread: mach_port_t,
    _ task: mach_port_t,
    _ exception: exception_type_t,
    _ code: mach_exception_data_t!,
    _ codeCnt: mach_msg_type_number_t
) -> kern_return_t {
    preconditionFailure()
}

#endif // canImport(Darwin) && !os(tvOS) && !os(watchOS)
