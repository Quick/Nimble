import Foundation

protocol BehaviorContext {
    func verifyBehaviors()
    func exampleNode(type: ExampleNodeType, name: String, closure: () -> Void, location: SourceLocation) -> ExampleNode
    func beforeEach(closure: () -> Void, location: SourceLocation)
    func afterEach(closure: () -> Void, location: SourceLocation)
}

@objc
class TSEmptyContext : BehaviorContext {
    init() {}

    func verifyBehaviors() {
        fail("Not allowed", file: __FILE__, line: __LINE__)
    }

    func exampleNode(type: ExampleNodeType, name: String, closure: () -> Void, location: SourceLocation) -> ExampleNode {
        fail("\(type)() is not allowed here", file: location.file, line: location.line)
        return ExampleNode(type: type, name: "Invalid \(type)()", parent: nil)
    }

    func beforeEach(closure: () -> Void, location: SourceLocation) {
        fail("beforeEach() is not allowed here", file: location.file, line: location.line)
    }

    func afterEach(closure: () -> Void, location: SourceLocation)  {
        fail("afterEach() is not allowed here", file: location.file, line: location.line)
    }
}

@objc
class TSSpecContext : BehaviorContext {
    var stack: Stack<ExampleNode>
    var root: ExampleNode { return stack.peek(index: 0) }

    init() {
        stack = Stack(items: [ExampleNode(type: .Spec, name: "")])
    }

    class func behaviors(closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) -> TSSpecContext {
        let previousContext = _SpecContext
        var spec = TSSpecContext()
        _SpecContext = spec
        closure()
        _SpecContext = previousContext
        return spec
    }

    func eachLeafExample(rootNode node: ExampleNode, closure: (leafNode: ExampleNode) -> Void) {
        for child in node.children {
            self.eachLeafExample(rootNode: child, closure: closure)
        }

        if node.isLeaf {
            closure(leafNode: node)
        }
    }

    func verifyBehaviors() {
        stack.whileFrozen {
            self.verifyNode(self.root)
        }
    }

    func verifyNode(node: ExampleNode) {
        for beforeEach in node.beforeEaches {
            beforeEach.run()
        }
        node.behavior.run()
        for child in node.children {
            self.verifyNode(child)
        }
        for afterEach in node.afterEaches {
            afterEach.run()
        }
    }

    func _verify(action: LogicValue, message: String, location: SourceLocation) {
        CurrentAssertionHandler.assert(action.getLogicValue(), message: message, location: location)
    }

    func exampleNode(type: ExampleNodeType, name: String, closure: () -> Void, location: SourceLocation) -> ExampleNode {
        let parentNode = stack.peek()
        var node = ExampleNode(type: type, name: name, parent: parentNode)
        _verify(stack.push(node), message: "Using \(type)() isn't allowed at this location", location: location)

        switch type {
        case .Describe, .Context, .Spec:
            closure()
        case .It:
            node.behavior = Behavior(block: closure, location: location)
        }

        parentNode.children.append(node)
        _verify(stack.pop(), message: "Using \(type)() isn't allowed at this location", location: location)
        return node
    }

    func beforeEach(closure: () -> Void, location: SourceLocation) {
        stack.peek().beforeEaches += Behavior(block: closure, location: location)
    }

    func afterEach(closure: () -> Void, location: SourceLocation) {
        let behavior = Behavior(block: closure, location: location)
        stack.peek().afterEaches.insert(behavior, atIndex: 0)
    }
}
