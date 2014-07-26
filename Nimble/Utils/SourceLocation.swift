import Foundation


@objc public class SourceLocation : Printable {
    let file: String
    let line: UInt

    init() {
        file = "Unknown File"
        line = 0
    }

    init(file: String, line: UInt) {
        self.file = file
        self.line = line
    }

    public var description: String {
        return "\(file):\(line)"
    }
}
