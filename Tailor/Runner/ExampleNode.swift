import Foundation

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
