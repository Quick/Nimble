import Dispatch
import Foundation

public typealias XCTAssertCrashSignalHandler = (Int32) -> Void

#if !os(watchOS) && canImport(XCTest)
import XCTest

/// Control whether XCTAssertCrash should skip or not if current process is being debugged.
/// The default is different depending on the platform.
/// ```swift
///  #if canImport(Darwin) && !os(tvOS) && !os(watchOS)
///     return false
///  #else
///     return true
///  #endif
/// ```
public var skipXCTAssertCrashIfIsBeingDebugged: Bool = {
#if canImport(Darwin) && !os(tvOS) && !os(watchOS)
    return false
#else
    return true
#endif
}()

/// Asserts that an expression crashes.
/// - Important: **The expression will not be evaluated if current process is being debugged.**
/// - Parameters:
///     - expression: An `expression` that can crash.
///     - message: An optional description of the failure.
///     - file: The file in which failure occurred.
///             Defaults to the file name of the test case in which this function was called.
///     - line: The line number on which failure occurred.
///             Defaults to the line number on which this function was called.
///     - signalHandler: An optional handler for signal that are produced by `expression`.
///                      `SIGILL`, `SIGABRT` or `0` (if `expression` did not crash)
///     - stdoutHandler: An optional handler for stdout that are produced by `expression`.
///     - stderrHandler: An optional handler for stderr that are produced by `expression`.
///     - skipIfBeingDebugged: Skip `expression` if process is being debugged.
///                            Use `skipXCTAssertCrashIfIsBeingDebugged` as default.
/// - Returns: A value of type `T?`, the result of evaluating the given `expression`.
///            `nil` if `expression` crashed.
@discardableResult
public func XCTAssertCrash<T>(
    _ expression: @escaping @autoclosure () -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line,
    signalHandler: (Int32) -> Void = { _ in },
    stdoutHandler: (String) -> Void = { _ in },
    stderrHandler: (String) -> Void = { _ in },
    skipIfBeingDebugged: Bool = skipXCTAssertCrashIfIsBeingDebugged
) -> T? {
    if skipIfBeingDebugged && isBeingDebugged {
        print("\(file):\(line):0: warning: Skip `XCTAssertCrash()` because current process is being debugged.")
        return nil
    }

    var signal: Int32 = 0
    var result: T?

#if canImport(Darwin) && !os(tvOS) && !os(watchOS)
    let driver = MachException.do(_:catch:)
#else
    let driver = PosixSignal.do(_:catch:)
#endif

    let stderrData = capture(from: STDERR_FILENO) {
        let stdoutData = capture(from: STDIN_FILENO) {
            let sema = DispatchSemaphore(value: 0)
            let thread: Thread
            let block: () -> Void = {
                driver({
                    result = expression()
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
        }
        stdoutHandler(String(data: stdoutData, encoding: .utf8) ?? "<failed to decode stdout>")
    }
    stderrHandler(String(data: stderrData, encoding: .utf8) ?? "<failed to decode stderr>")

    if signal == 0 {
        XCTFail(message(), file: file, line: line)
    } else {
        signalHandler(signal)
    }
    return result
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

#endif // !os(watchOS) && canImport(XCTest)

/// Returns true if the current process is being debugged (either
/// running under the debugger or has a debugger attached post facto).
/// [Technical Q&A QA1361](https://developer.apple.com/library/archive/qa/qa1361/_index.html)
var isBeingDebugged: Bool {
#if canImport(Darwin)
    var mib: [Int32] = [
        CTL_KERN, KERN_PROC, KERN_PROC_PID, ProcessInfo.processInfo.processIdentifier
    ]
    var info = kinfo_proc()
    var size = MemoryLayout<kinfo_proc>.size
    _ = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
    return info.kp_proc.p_flag & P_TRACED != 0
#elseif os(Linux)
    let statuses = try? String(contentsOfFile: "/proc/self/status").components(separatedBy: .newlines)
    for status in statuses ?? [] where status.hasPrefix("TracerPid:") {
        return status.components(separatedBy: .whitespaces).last.map(Int.init) != 0
    }
    return false
#else
    #warning("`isBeingDebugged` only supports Darwin and Linux.")
#endif
}

#if canImport(Darwin)
func kernCheck(_ block: @autoclosure () -> kern_return_t, file: StaticString = #file, line: UInt = #line) {
    let result = block()
    assert(result == KERN_SUCCESS, file: file, line: line)
}
#endif

// MARK: - private

// MARK: Register Signal Handler to Thread Dictionary
extension Thread {
    static let SignalHandlerKey = "XCTAssertCrash.SignalHandler"

    func registerSignalHandler(_ handler: @escaping XCTAssertCrashSignalHandler) {
        threadDictionary[Thread.SignalHandlerKey] = handler
    }

    @discardableResult
    func unregisterSignalHandler() -> XCTAssertCrashSignalHandler? {
        defer { threadDictionary[Thread.SignalHandlerKey] = nil }
        return threadDictionary[Thread.SignalHandlerKey] as? XCTAssertCrashSignalHandler
    }
}

// swiftlint:disable identifier_name

/// Redirect file descriptor
/// - Parameter fd: A file descripter that capture output.
/// - Parameter expression: An expression that can produce output.
private func capture(from fd: Int32, _ expression: () -> Void) -> Data {
    let pipe = Pipe()
    let orig_fd: Int32 = fd
    let save_fd = dup(fd)
    let new_fd = pipe.fileHandleForWriting.fileDescriptor
    dup2(new_fd, orig_fd)
    close(new_fd)

    expression()

    _ = dup2(save_fd, orig_fd)
    close(save_fd)
    return pipe.fileHandleForReading.readDataToEndOfFile()
}
