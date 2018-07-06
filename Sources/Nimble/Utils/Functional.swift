import Foundation

extension Sequence {
    internal func all(_ predicate: (Iterator.Element) -> Bool) -> Bool {
        for item in self {
            if !predicate(item) {
                return false
            }
        }
        return true
    }
}
