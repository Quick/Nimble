import Foundation


struct Stack<T> {
    var items: T[]
    var frozen: Bool

    init(items: T[]) {
        self.items = items.copy()
        frozen = false
    }

    func peek(index: Int? = nil) -> T {
        if index {
            return items[index!]
        } else {
            return items[items.endIndex - 1]
        }
    }

    mutating func push(item: T) -> Bool {
        if !frozen {
            items.append(item)
        }
        return !frozen
    }

    mutating func pop() -> T? {
        if !frozen {
            return items.removeLast()
        }
        return nil
    }

    mutating func whileFrozen(closure: () -> Void) {
        let originalState = frozen
        frozen = true
        closure()
        frozen = originalState
    }
}
