import Foundation

// WIP: not finished yet.
// Q: how are we going to wrap the describe blocks to the user?

class Node {
    var name = ""
    var children = Node[]()
    var exampleBlock = ({() -> () in })
    var beforeEach = ({() -> () in })
    var afterEach = ({() -> () in })
    weak var parent: Node?

    init(name: String) {
        self.name = name
    }

    func removeFromParentNode() {
        self.parent?.removeChild(self)
    }

    func removeChild(node: Node) {
        var indexToRemove: Int?
        for (index, object) in enumerate(self.children) {
            if (object === node) {
                indexToRemove = index
            }
        }

        if indexToRemove {
            self.children[indexToRemove!..indexToRemove!+1] = []
        }
    }
}

var rootNode = Node(name: "")
var nodesStack = [rootNode]

func runSpecs(node: Node) {
    node.beforeEach()
    node.exampleBlock()
    for child in node.children {
        runSpecs(child)
    }
    node.afterEach()
}

func runSpecs() {
    runSpecs(rootNode)
}

func clearKnownSpecs() {
    rootNode = Node(name: "")
    nodesStack = [rootNode]
}

func textForNode(leafNode: Node) -> String {
    var n: Node? = leafNode
    var components = String[]()
    while let node = n {
        components.insert(node.name, atIndex: 0)
    }
    return " ".join(components)
}

func describe(name: String, behaviors: () -> ()) -> Node {
    var node = Node(name: name)
    let parentNode = nodesStack[nodesStack.endIndex - 1]
    nodesStack.append(node)
    node.parent = parentNode
    behaviors()
    return nodesStack.removeLast()
}

func when(name: String, behaviors: () -> ()) -> Node {
    return describe(name, behaviors)
}

func it(name: String, behavior: () -> ()) -> Node {
    var node = Node(name: name)
    let parentNode = nodesStack[nodesStack.endIndex - 1]
    node.parent = parentNode
    node.exampleBlock = behavior
    parentNode.children.append(node)
    return node
}
