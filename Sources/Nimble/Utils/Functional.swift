
extension Sequence {
    internal func all(predicate: (Iterator.Element) -> Bool) -> Bool {
        return !contains { !predicate($0) }
    }
}
