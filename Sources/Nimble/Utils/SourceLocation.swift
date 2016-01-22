import Foundation

#if _runtime(_ObjC)
public typealias FileString = String
#else
public typealias FileString = StaticString
#endif

public class SourceLocation : NSObject {
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
