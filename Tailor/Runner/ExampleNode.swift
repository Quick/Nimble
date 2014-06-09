import Foundation

enum ExampleNodeType : Printable {
case Spec
case Describe, Context, It

    var description: String {
        switch self {
        case .Spec:
            return "spec"
        case .Describe:
            return "describe"
        case .Context:
            return "context"
        case .It:
            return "it"
        }
    }
}

// data structure for example groups and examples
@objc
class ExampleNode : Printable {
    let type: ExampleNodeType
    var name = ""
    var children: ExampleNode[]
    var behavior: Behavior
    var beforeEaches: Behavior[]
    var afterEaches: Behavior[]
    weak var parent: ExampleNode?

    var parents: Array<ExampleNode> {
        var ancestor = parent
        var parents = Array<ExampleNode>()
        while (ancestor) {
            parents.append(ancestor!)
            ancestor = ancestor!.parent
        }
        return parents
    }

    var isLeaf: Bool { return children.count == 0 }
    var description: String {
        return "<\(name): \(children)>"
    }

    init(type: ExampleNodeType, name: String, parent: ExampleNode? = nil) {
        self.type = type
        self.name = name
        self.parent = parent
        behavior = Behavior()
        beforeEaches = Behavior[]()
        afterEaches = Behavior[]()
        children = ExampleNode[]()
    }

    func runBeforeEaches() {
        for beforeEach in beforeEaches {
            beforeEach.run()
        }
    }

    func runAfterEaches() {
        for afterEach in afterEaches {
            afterEach.run()
        }
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
