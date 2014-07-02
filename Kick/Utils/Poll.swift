import Foundation

func pollBlock(#pollInterval: NSTimeInterval, #timeoutInterval: NSTimeInterval, expression: () -> Bool) -> Bool {
    let startDate = NSDate()
    var pass: Bool
    do {
        pass = expression()
        let runDate = NSDate().addTimeInterval(pollInterval) as NSDate
        NSRunLoop.mainRunLoop().runUntilDate(runDate)
    } while(!pass && NSDate().timeIntervalSinceDate(startDate) < timeoutInterval);
    return pass
}
