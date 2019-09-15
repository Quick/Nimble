import Dispatch
import Foundation

// MARK: Disabling _swift_reportFatalErrorsToDebugger

struct SwiftReportFatalErrorsToDebugger {
    static func disable() {
        guard originalValue, isBeingDebugged else { return }
        queue.sync {
            pointer?.pointee = false
            registeredThreads.insert(Thread.current)
        }
    }

    static func restore() {
        guard originalValue, isBeingDebugged else { return }
        queue.sync {
            registeredThreads.remove(Thread.current)
            if registeredThreads.isEmpty {
                pointer?.pointee = true
            }
        }
    }

    // MARK: private

    private static let queue = DispatchQueue(label: "XCTAssertCrash.MachExceptionHandler")
    private static var registeredThreads = Set<Thread>()
    private static let name = "_swift_reportFatalErrorsToDebugger"
    private static let pointer = dlopen(nil, RTLD_GLOBAL)
        .map { dlsym($0, name) }
        .flatMap { unsafeBitCast($0, to: UnsafeMutablePointer<Bool>.self) }
    private static let originalValue = pointer?.pointee ?? false
}
