import Foundation

struct Behavior {
    let block: () -> Void
    let file: String
    let line: Int
    var startDate: NSDate?
    var endDate: NSDate?

    init() {
        block = ({})
        file = "Empty Behavior <NO FILE>"
        line = 0
    }

    init(block: () -> Void, file: String, line: Int) {
        self.block = block
        self.file = file
        self.line = line
    }

    mutating func run() {
        startDate = NSDate()
        block()
        endDate = NSDate()
    }
}
