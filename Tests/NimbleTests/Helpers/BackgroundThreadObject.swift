import Foundation

// Simulates an object that *really* cares what thread it is run on.
// Supposed to replicate what happens if a NSManagedObject ends up
// in a notification and is picked up by Nimble
class BackgroundThreadObject: CustomDebugStringConvertible {
    var debugDescription: String {
        assert(!Thread.isMainThread)
        return "BackgroundThreadObject"
    }
}
