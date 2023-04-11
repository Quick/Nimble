import Foundation
import Nimble

// Simulates an object that *really* cares what thread it is run on.
// Supposed to replicate what happens if a NSManagedObject ends up
// in a notification and is picked up by Nimble
class BackgroundThreadObject: CustomDebugStringConvertible {
    var debugDescription: String {
        if Thread.isMainThread {
            fail("This notification was accessed on the main thread when it should have been handled on the thread it was received on")
        }
        return "BackgroundThreadObject"
    }
}
