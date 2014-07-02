import Foundation


func stringify<S: Sequence>(value: S) -> String {
    var generator = value.generate()
    var strings = String[]()
    var value: S.GeneratorType.Element?
    do {
        value = generator.next()
        if value {
            strings.append(stringify(value))
        }
    } while value
    let str = ", ".join(strings)
    return "[\(str)]"
}

func stringify<T>(value: T?) -> String {
    if value is NSArray? {
        return (value as NSArray).componentsJoinedByString(", ")
    }
    return "\(value)"
}

struct box<T> {
    let value: T
    init(_ val: T) { value = val }
    func str() -> String {
        return stringify(value)
    }
}
box(1).str()
box("hello").str()
box([1, 2, 3]).str()
box(NSArray(array: [1, 2, 3])).str()


class expect {
    let expression: () -> Any?
    init(_ expression: @auto_closure () -> Any?) {
        self.expression = expression
    }

    func verify(pass: Bool) -> String {
        if pass {
            return "PASS"
        } else {
            return "FAIL"
        }
    }

    func toEqual<U: Equatable>(expected: U?) -> String {
        let actual = expression() as? U
        return verify(actual && actual! == expected)
    }

    func toEqual(expected: String?) -> String {
        let actual = expression() as? String?
        return verify(actual && actual! == expected)
    }

    func toEqual<S: Sequence where S.GeneratorType.Element: Equatable>(expected: S?) -> String {
        let actual = expression() as? S?
        return verify(actual && equal(actual!!, expected!))
    }
}

// all need to pass before this can be a viable solution
expect(1 as Int).toEqual(1 as Int)
expect(1).toEqual(1)
expect("hello").toEqual("hello")
expect(NSNumber.numberWithInteger(1)).toEqual(NSNumber.numberWithInteger(1))
expect([1, 2, 3]).toEqual([1, 2, 3])
expect(1 as CInt?).toEqual(1 as CInt?)
expect([1, 2, 3] as Array<CInt>).toEqual([1, 2, 3] as Array<CInt>)
expect(1 as CInt?).toEqual(1)
expect(1).toEqual(1 as CInt?)

