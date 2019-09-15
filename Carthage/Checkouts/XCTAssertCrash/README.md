# XCTAssertCrash
Asserts that an expression crashes by using Mach Exception Handler or POSIX Signal Handler.

On Apple Platforms except tvOS, it uses Mach Exception Handler.  
On other Platforms like Linux or tvOS, it uses POSIX Signal Handler. 

[![Build Status](https://dev.azure.com/norio-nomura/XCTAssertCrash/_apis/build/status/norio-nomura.XCTAssertCrash?branchName=master)](https://dev.azure.com/norio-nomura/XCTAssertCrash/_build/latest?definitionId=8&branchName=master)

## Usage

```swift
/// Asserts that an expression crashes.
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
) -> T?
```

## Limitations

### Mach Exception Handler
- `XCTAssertCrash` can not handle crashes caused by `abort()`.
- `XCTAssertCrash` can not handle the breakpoint set in expression. On detecting a stop at a breakpoint set by the debugger, `XCTAssertCrash` generates `assertionFailure()`.

### POSIX Signal Handler
-  `lldb` will catch the signal and stopp on crash before `XCTAssertCrash` detects them.
- **So, if process is beingd debugged, `XCTAssertCrash` will skip evaluation the expression by default.**  
    To avoid this behavior,
    - Set `skipXCTAssertCrashIfIsBeingDebugged` to `false`.  
    or  
    - Disable debug.  
        e.g. In Xcode, go to 'Edit Scheme > Test > Info' and uncheck 'Debug Executable'.


## Author

Norio Nomura

## License

This package is available under the MIT license. See the LICENSE file for more info.

## References
- [Partial functions in Swift, Part 2: Catching precondition failures](http://www.cocoawithlove.com/blog/2016/02/02/partial-functions-part-two-catching-precondition-failures.html) by Matt Gallagher
- [Friday Q&A 2013-01-11: Mach Exception Handlers](https://www.mikeash.com/pyblog/friday-qa-2013-01-11-mach-exception-handlers.html) by Landon Fuller
- Mac OS X and iOS Internals by Jonathan Levin
- [The Darwin Kernel](https://github.com/apple/darwin-xnu) by Apple
