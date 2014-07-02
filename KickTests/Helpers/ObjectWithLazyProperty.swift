import Cocoa

class ObjectWithLazyProperty {
    init() {}
    @lazy var value: String = "hello"
}
