import Foundation

protocol BehaviorContext {
    func verifyBehaviors()
    func exampleNode(type: ExampleNodeType, name: String, closure: () -> Void, file: String, line: Int) -> ExampleNode
    func beforeEach(closure: () -> Void, file: String, line: Int)
    func afterEach(closure: () -> Void, file: String, line: Int)
}

@objc
class NoBehavior : BehaviorContext {
    init() {}

    func verifyBehaviors() {
        fail("Not allowed", file: __FILE__, line: __LINE__)
    }

    func exampleNode(type: ExampleNodeType, name: String, closure: () -> Void, file: String, line: Int) -> ExampleNode {
        fail("\(type)() is not allowed here", file: file, line: line)
        return ExampleNode(type: type, name: "Invalid \(type)()", parent: nil)
    }

    func beforeEach(closure: () -> Void, file: String, line: Int) {
        fail("beforeEach() is not allowed here", file: file, line: line)
    }

    func afterEach(closure: () -> Void, file: String, line: Int)  {
        fail("afterEach() is not allowed here", file: file, line: line)
    }
}

@objc
class SpecBehavior : BehaviorContext {
    var stack: Stack<ExampleNode>
    var root: ExampleNode { return stack.peek(index: 0) }

    init() {
        stack = Stack(items: [ExampleNode(type: .Spec, name: "")])
    }

    class func behaviors(closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) -> SpecBehavior {
        var spec = SpecBehavior()
        _SpecContext = spec
        closure()
        _SpecContext = NoBehavior()
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

    func exampleNode(type: ExampleNodeType, name: String, closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) -> ExampleNode {
        let parentNode = stack.peek()
        var node = ExampleNode(type: type, name: name, parent: parentNode)
        _verify(stack.push(node), message: "Using \(type)() isn't allowed at this location", file: file, line: line)

        switch type {
        case .Describe, .Context, .Spec:
            closure()
        case .It:
            node.behavior = Behavior(block: closure, file: file, line: line)
        }

        parentNode.children.append(node)
        _verify(stack.pop(), message: "Using \(type)() isn't allowed at this location", file: file, line: line)
        return node
    }

    func beforeEach(closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
        stack.peek().beforeEach = Behavior(block: closure, file: file, line: line)
    }

    func afterEach(closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
        stack.peek().afterEach = Behavior(block: closure, file: file, line: line)
    }
}
