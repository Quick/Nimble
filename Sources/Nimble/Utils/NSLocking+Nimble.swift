import Foundation

extension NSLocking {
    internal func sync<T>(_ closure: () throws -> T) rethrows -> T {
        lock()
        defer {
            unlock()
        }
        return try closure()
    }
}
