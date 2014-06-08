import Foundation

@objc
class SpecBehavior {
    var stack: Stack<ExampleNode>
    var root: ExampleNode { return stack.peek(index: 0) }

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
