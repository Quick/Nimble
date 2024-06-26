import Foundation

// Ideally we would always use `StaticString` as the type for tracking the file name
// that expectations originate from, for consistency with `assert` etc. from the
// stdlib, and because recent versions of the XCTest overlay require `StaticString`
// when calling `XCTFail`. Under the Objective-C runtime (i.e. building on Mac), we
// have to use `String` instead because StaticString can't be generated from Objective-C
#if !canImport(Darwin)
public typealias FileString = StaticString
#else
public typealias FileString = String
#endif

public final class SourceLocation: NSObject, Sendable {
    public let fileID: String
    @available(*, deprecated, renamed: "filePath")
    public var file: FileString { filePath }
    public let filePath: FileString
    public let line: UInt
    public let column: UInt

    override init() {
        fileID = "Unknown/File"
        filePath = "Unknown File"
        line = 0
        column = 0
    }

    init(fileID: String, filePath: FileString, line: UInt, column: UInt) {
        self.fileID = fileID
        self.filePath = filePath
        self.line = line
        self.column = column
    }

    override public var description: String {
        return "\(filePath):\(line):\(column)"
    }
}
