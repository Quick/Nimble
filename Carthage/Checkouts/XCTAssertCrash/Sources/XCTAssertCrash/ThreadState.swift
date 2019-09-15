#if canImport(Darwin)

import Foundation

// swiftlint:disable identifier_name

protocol ThreadState {
    init()
    static var count: mach_msg_type_number_t { get }
    static var flavor: Int32 { get }
}

extension ThreadState {
    /// `XX_THREAD_STATE_COUNT`
    static var count: mach_msg_type_number_t {
        return mach_msg_type_number_t(MemoryLayout<Self>.size / MemoryLayout<Int32>.size)
    }

    /// Wrap `thread_get_state`
    ///
    /// - Parameter thread: A thread
    init(from thread: mach_port_t) {
        self.init()
        withUnsafeMutablePointer(to: &self) { pointer -> Void in
            pointer.withMemoryRebound(to: natural_t.self, capacity: 1) { state -> Void in
                var count = Self.count
                kernCheck(thread_get_state(thread, Self.flavor, state, &count))
            }
        }
    }

    /// Wrap `thread_set_state`
    ///
    /// - Parameter thread: A thread
    mutating func set(to thread: mach_port_t) {
        withUnsafeMutablePointer(to: &self) { pointer -> Void in
            pointer.withMemoryRebound(to: natural_t.self, capacity: 1) { state -> Void in
                kernCheck(thread_set_state(thread, Self.flavor, state, Self.count))
            }
        }
    }
}

#if arch(x86_64)

// MARK: - x86_THREAD_STATE64

extension x86_thread_state64_t: ThreadState {
    static var flavor: Int32 { return x86_THREAD_STATE64 }
}

extension thread_state_t {
    var x86_thread_state64: x86_thread_state64_t {
        get { return withMemoryRebound(to: x86_thread_state64_t.self, capacity: 1) { $0.pointee } }
        nonmutating set { withMemoryRebound(to: x86_thread_state64_t.self, capacity: 1) { $0.pointee = newValue } }
    }
}

#elseif arch(arm64)

// MARK: - ARM_THREAD_STATE64

private let brkMask: UInt32 = 0b11111111_111_0000000000000000_11111
private let brkMaskedInstruction: UInt32 = 0b11010100_001_0000000000000000_00000

extension arm_thread_state64_t: ThreadState {
    static var flavor: Int32 { return ARM_THREAD_STATE64 }

    var instructionPointedByProgramCounter: UnsafePointer<UInt32> {
        return UnsafePointer<UInt32>(bitPattern: UInt(__pc))!
    }

    var isProgramCounterPointingBRK: Bool {
        return instructionPointedByProgramCounter.pointee & brkMask == brkMaskedInstruction
    }

    mutating func setProgramCounter<T>(_ function: T) {
        __pc = unsafeBitCast(function, to: __uint64_t.self)
    }
}

extension arm_debug_state64_t: ThreadState {
    static var flavor: Int32 { return ARM_DEBUG_STATE64 }
}

extension thread_state_t {
    var arm_debug_state64: arm_debug_state64_t {
        get { return withMemoryRebound(to: arm_debug_state64_t.self, capacity: 1) { $0.pointee } }
        nonmutating set { withMemoryRebound(to: arm_debug_state64_t.self, capacity: 1) { $0.pointee = newValue } }
    }
}

#endif // arch(arm64)

#endif // canImport(Darwin)
