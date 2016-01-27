import Foundation

public typealias FileString = StaticString

public final class SourceLocation : NSObject {
    public let file: FileString
    public let line: UInt

    override init() {
        file = "Unknown File"
        line = 0
    }

    init(file: FileString, line: UInt) {
        self.file = file
        self.line = line
    }

    override public var description: String {
        return "\(file):\(line)"
    }
}
