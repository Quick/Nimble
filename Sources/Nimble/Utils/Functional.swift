import Foundation

extension SequenceType {
    internal func all(fn: Generator.Element -> Bool) -> Bool {
        for item in self {
            if !fn(item) {
                return false
            }
        }
        return true
    }
}

internal func all<T>(array: [T], fn: (T) -> Bool) -> Bool {
    for item in array {
        if !fn(item) {
            return false
        }
    }
    return true
}

