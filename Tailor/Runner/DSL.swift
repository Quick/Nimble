import Foundation


var _SpecContext: BehaviorContext = NoBehavior()

func behaviors(closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) -> SpecBehavior {
    return SpecBehavior.behaviors(closure, file: file, line: line)
}

func beforeEach(closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
    _SpecContext.beforeEach(closure, file: file, line: line)
}

func afterEach(closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
    _SpecContext.afterEach(closure, file: file, line: line)
}

func describe(name: String, closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
    _SpecContext.exampleNode(.Describe, name: name, closure: closure, file: file, line: line)
}

func context(name: String, closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
    _SpecContext.exampleNode(.Context, name: name, closure: closure, file: file, line: line)
}

func it(name: String, closure: () -> Void, file: String = __FILE__, line: Int = __LINE__) {
    _SpecContext.exampleNode(.It, name: name, closure: closure, file: file, line: line)
}
