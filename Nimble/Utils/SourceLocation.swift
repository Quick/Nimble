import Foundation


@objc class SourceLocation : Printable {
    let file: String
    let line: Int

    init() {
        file = "Unknown File"
        line = 0
    }

    init(file: String, line: Int) {
        self.file = file
        self.line = line
    }

    var description: String {
        return "\(file):\(line)"
    }
}
