import Foundation


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
