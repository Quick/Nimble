import Foundation

// WIP: not finished yet.
// Q: how are we going to wrap the describe blocks to the user?

struct Behavior {
    let block: () -> Void
    let file: String
    let line: Int
    var startDate: NSDate?
    var endDate: NSDate?

    init() {
        block = ({})
        file = "Empty Behavior <NO FILE>"
        line = 0
    }

    init(block: () -> Void, file: String, line: Int) {
        self.block = block
        self.file = file
        self.line = line
    }

    mutating func run() {
        startDate = NSDate()
        block()
        endDate = NSDate()
    }
}

@objc
class ExampleNode : Sequence, Printable {
    var name = ""
    var children: ExampleNode[]
    var behavior: Behavior
    var beforeEach: Behavior
    var afterEach: Behavior
    weak var parent: ExampleNode?

    init(name: String, parent: ExampleNode? = nil) {
        self.name = name
        self.parent = parent
        behavior = Behavior()
        beforeEach = Behavior()
        afterEach = Behavior()
        children = ExampleNode[]()
    }

    var description: String {
        return "<\(name): \(children)>"
    }

    subscript(index: Int) -> ExampleNode {
        return self.children[index]
    }

    func generate() -> IndexingGenerator<ExampleNode[]> {
        return self.children.generate()
    }

    func removeAllChildren() {
        children.map { self.removeChild($0) }
    }

    func removeFromParentNode() {
        self.parent?.removeChild(self)
    }

    func removeChild(node: ExampleNode) {
        var indexToRemove: Int?
        for (index, object) in enumerate(self.children) {
            if (object === node) {
                node.parent = nil
                indexToRemove = index
            }
        }

        if indexToRemove {
            self.children[indexToRemove!..indexToRemove!+1] = []
        }
    }
}

struct Stack<T> {
    var items: T[]
    var frozen: Bool

    init(items: T[] = T[]()) {
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

@objc
class SpecBehavior {
    var stack: Stack<ExampleNode>
    var root: ExampleNode { stack.peek(index: 0) }

    init() {
        stack = Stack(items: [ExampleNode(name: "")])
    }

    class func behaviors(closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) -> SpecBehavior {
        var spec = SpecBehavior()
        _SpecContext = spec
        closure()
        _SpecContext = nil
        return spec
    }

    func clear() {
        root.removeAllChildren()
        stack = Stack<ExampleNode>(items: [root])
    }

    func verifyBehaviors() {
        stack.whileFrozen {
            self.verifyNode(self.root)
        }
    }

    func verifyNode(node: ExampleNode) {
        node.beforeEach.run()
        node.behavior.run()
        for child in node.children {
            self.verifyNode(child)
        }
        node.afterEach.run()
    }

    func _verify(action: LogicValue, message: String, file: String, line: Int) {
        CurrentAssertionHandler.assert(action.getLogicValue(), message: message, file: file, line: line)
    }

    func _pushNodeOnStack(node: ExampleNode, file: String, line: Int) {
        _verify(stack.push(node), message: "This isn't not allowed in the current location", file: file, line: line)
    }

    func _popNodeOnStack(file: String, line: Int) -> ExampleNode {
        if let node = stack.pop() {
            return node
        } else {
            _verify(false, message: "This isn't not allowed in the current location", file: file, line: line)
            return ExampleNode(name: "Bad State", parent: nil)
        }
    }

    func describe(name: String, closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) -> ExampleNode {
        let parentNode = stack.peek()
        var node = ExampleNode(name: name, parent: parentNode)
        _verify(stack.push(node), message: "Using describe() isn't allowed in this location", file: file, line: line)
        closure()
        parentNode.children.append(node)
        _verify(stack.pop(), message: "Using describe() isn't allowed in this location", file: file, line: line)
        return node
    }

    func it(name: String, closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) -> ExampleNode {
        let parentNode = stack.peek()
        var node = ExampleNode(name: name, parent: parentNode)
        node.behavior = Behavior(block: closure, file: file, line: line)
        parentNode.children.append(node)
        return node
    }

    func beforeEach(closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
        stack.peek().beforeEach = Behavior(block: closure, file: file, line: line)
    }

    func afterEach(closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
        stack.peek().afterEach = Behavior(block: closure, file: file, line: line)
    }
}

var _SpecContext: SpecBehavior?

func behaviors(closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) -> SpecBehavior {
    var spec = SpecBehavior()
    _SpecContext = spec
    closure()
    _SpecContext = nil
    return spec
}

func beforeEach(closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
    _SpecContext!.beforeEach(closure, file: file, line: line)
}

func afterEach(closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
    _SpecContext!.afterEach(closure, file: file, line: line)
}

func describe(name: String, closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
    _SpecContext!.describe(name, closure: closure, file: file, line: line)
}

func context(name: String, closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
    _SpecContext!.describe(name, closure: closure, file: file, line: line)
}

func it(name: String, closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
    _SpecContext!.it(name, closure: closure, file: file, line: line)
}
