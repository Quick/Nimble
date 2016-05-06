import Foundation

extension Sequence {
    internal func all(_ fn: Iterator.Element -> Bool) -> Bool {
        for item in self {
            #if swift(>=3)
                if !fn(item) {
                    return false
                }
            #else
                if !fn(item as! Iterator.Element) {
                    return false
                }
            #endif
        }
        return true
    }
}
