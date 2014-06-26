import Foundation

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

