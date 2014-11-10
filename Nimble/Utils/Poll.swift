import Foundation

func _pollBlock(#pollInterval: NSTimeInterval, #timeoutInterval: NSTimeInterval, expression: () -> Bool) -> Bool {
    let startDate = NSDate()
    var pass: Bool
    do {
        pass = expression()
        if pass {
            break
        }

        let runDate = NSDate().dateByAddingTimeInterval(pollInterval) as NSDate
        NSRunLoop.mainRunLoop().runUntilDate(runDate)
    } while(NSDate().timeIntervalSinceDate(startDate) < timeoutInterval);

    return pass
}
