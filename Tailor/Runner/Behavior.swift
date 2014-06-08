import Foundation

class Behavior {
    let block: () -> Void
    let location: SourceLocation
    var startDate: NSDate?
    var endDate: NSDate?

    init() {
        block = ({})
        location = SourceLocation()
    }

    init(block: () -> Void, location: SourceLocation) {
        self.block = block
        self.location = location
    }

    func run() {
        startDate = NSDate()
        block()
        endDate = NSDate()
    }
}
