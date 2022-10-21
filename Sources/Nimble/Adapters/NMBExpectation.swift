#if !os(WASI)

#if canImport(Darwin) && !SWIFT_PACKAGE
import class Foundation.NSObject
import typealias Foundation.TimeInterval
import enum Dispatch.DispatchTimeInterval

private func from(objcPredicate: NMBPredicate) -> Predicate<NSObject> {
    return Predicate { actualExpression in
        let result = objcPredicate.satisfies(({ try actualExpression.evaluate() }),
                                             location: actualExpression.location)
        return result.toSwift()
    }
}

// Equivalent to Expectation, but for Nimble's Objective-C interface
public class NMBExpectation: NSObject {
    internal let _actualBlock: () -> NSObject?
    internal var _negative: Bool
    internal let _file: FileString
    internal let _line: UInt
    internal var _timeout: DispatchTimeInterval = .seconds(1)

    @objc public init(actualBlock: @escaping () -> NSObject?, negative: Bool, file: FileString, line: UInt) {
        self._actualBlock = actualBlock
        self._negative = negative
        self._file = file
        self._line = line
    }

    private var expectValue: SyncExpectation<NSObject> {
        return expect(file: _file, line: _line, self._actualBlock() as NSObject?)
    }

    @objc public var withTimeout: (TimeInterval) -> NMBExpectation {
        return { timeout in self._timeout = timeout.dispatchInterval
            return self
        }
    }

    @objc public var to: (NMBPredicate) -> NMBExpectation {
        return { predicate in
            self.expectValue.to(from(objcPredicate: predicate))
            return self
        }
    }

    @objc public var toWithDescription: (NMBPredicate, String) -> NMBExpectation {
        return { predicate, description in
            self.expectValue.to(from(objcPredicate: predicate), description: description)
            return self
        }
    }

    @objc public var toNot: (NMBPredicate) -> NMBExpectation {
        return { predicate in
            self.expectValue.toNot(from(objcPredicate: predicate))
            return self
        }
    }

    @objc public var toNotWithDescription: (NMBPredicate, String) -> NMBExpectation {
        return { predicate, description in
            self.expectValue.toNot(from(objcPredicate: predicate), description: description)
            return self
        }
    }

    @objc public var notTo: (NMBPredicate) -> NMBExpectation { return toNot }

    @objc public var notToWithDescription: (NMBPredicate, String) -> NMBExpectation { return toNotWithDescription }

    @objc public var toEventually: (NMBPredicate) -> Void {
        return { predicate in
            self.expectValue.toEventually(
                from(objcPredicate: predicate),
                timeout: self._timeout,
                description: nil
            )
        }
    }

    @objc public var toEventuallyWithDescription: (NMBPredicate, String) -> Void {
        return { predicate, description in
            self.expectValue.toEventually(
                from(objcPredicate: predicate),
                timeout: self._timeout,
                description: description
            )
        }
    }

    @objc public var toEventuallyNot: (NMBPredicate) -> Void {
        return { predicate in
            self.expectValue.toEventuallyNot(
                from(objcPredicate: predicate),
                timeout: self._timeout,
                description: nil
            )
        }
    }

    @objc public var toEventuallyNotWithDescription: (NMBPredicate, String) -> Void {
        return { predicate, description in
            self.expectValue.toEventuallyNot(
                from(objcPredicate: predicate),
                timeout: self._timeout,
                description: description
            )
        }
    }

    @objc public var toNotEventually: (NMBPredicate) -> Void {
        return toEventuallyNot
    }

    @objc public var toNotEventuallyWithDescription: (NMBPredicate, String) -> Void {
        return toEventuallyNotWithDescription
    }

    @objc public var toNever: (NMBPredicate) -> Void {
        return { predicate in
            self.expectValue.toNever(
                from(objcPredicate: predicate),
                until: self._timeout,
                description: nil
            )
        }
    }

    @objc public var toNeverWithDescription: (NMBPredicate, String) -> Void {
        return { predicate, description in
            self.expectValue.toNever(
                from(objcPredicate: predicate),
                until: self._timeout,
                description: description
            )
        }
    }

    @objc public var neverTo: (NMBPredicate) -> Void {
        return toNever
    }

    @objc public var neverToWithDescription: (NMBPredicate, String) -> Void {
        return toNeverWithDescription
    }

    @objc public var toAlways: (NMBPredicate) -> Void {
        return { predicate in
            self.expectValue.toAlways(
                from(objcPredicate: predicate),
                until: self._timeout,
                description: nil
            )
        }
    }

    @objc public var toAlwaysWithDescription: (NMBPredicate, String) -> Void {
        return { predicate, description in
            self.expectValue.toAlways(
                from(objcPredicate: predicate),
                until: self._timeout,
                description: description
            )
        }
    }

    @objc public var alwaysTo: (NMBPredicate) -> Void {
        return toAlways
    }

    @objc public var alwaysToWithDescription: (NMBPredicate, String) -> Void {
        return toAlwaysWithDescription
    }

    @objc public class func failWithMessage(_ message: String, file: FileString, line: UInt) {
        fail(message, location: SourceLocation(file: file, line: line))
    }
}

#endif

#endif // #if !os(WASI)
