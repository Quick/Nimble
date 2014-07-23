import Foundation


@objc public class SourceLocation : Printable {
    let file: String
    let line: UInt

    init() {
        file = "Unknown File"
        line = 0
    }

    init(file: String, line: Int) {
        self.file = file
        self.line = UInt(line)
    }

    public var description: String {
        return "\(file):\(line)"
    }
}
