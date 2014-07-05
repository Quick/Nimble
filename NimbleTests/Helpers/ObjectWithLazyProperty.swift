import Foundation

class ObjectWithLazyProperty {
    init() {}
    @lazy var value: String = "hello"
}
