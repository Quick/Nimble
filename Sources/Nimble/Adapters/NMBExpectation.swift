#if !os(WASI)

#if canImport(Darwin)
import class Foundation.NSObject
import typealias Foundation.TimeInterval

private func from(objcMatcher: NMBMatcher) -> Matcher<NSObject> {
    return Matcher { actualExpression in
        let result = objcMatcher.satisfies(({ try actualExpression.evaluate() }),
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
    internal var _timeout: NimbleTimeInterval = .seconds(1)

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
        return { timeout in self._timeout = timeout.nimbleInterval
            return self
        }
    }

    @objc public var to: (NMBMatcher) -> NMBExpectation {
        return { matcher in
            self.expectValue.to(from(objcMatcher: matcher))
            return self
        }
    }

    @objc public var toWithDescription: (NMBMatcher, String) -> NMBExpectation {
        return { matcher, description in
            self.expectValue.to(from(objcMatcher: matcher), description: description)
            return self
        }
    }

    @objc public var toNot: (NMBMatcher) -> NMBExpectation {
        return { matcher in
            self.expectValue.toNot(from(objcMatcher: matcher))
            return self
        }
    }

    @objc public var toNotWithDescription: (NMBMatcher, String) -> NMBExpectation {
        return { matcher, description in
            self.expectValue.toNot(from(objcMatcher: matcher), description: description)
            return self
        }
    }

    @objc public var notTo: (NMBMatcher) -> NMBExpectation { return toNot }

    @objc public var notToWithDescription: (NMBMatcher, String) -> NMBExpectation { return toNotWithDescription }

    @objc public var toEventually: (NMBMatcher) -> Void {
        return { matcher in
            self.expectValue.toEventually(
                from(objcMatcher: matcher),
                timeout: self._timeout,
                description: nil
            )
        }
    }

    @objc public var toEventuallyWithDescription: (NMBMatcher, String) -> Void {
        return { matcher, description in
            self.expectValue.toEventually(
                from(objcMatcher: matcher),
                timeout: self._timeout,
                description: description
            )
        }
    }

    @objc public var toEventuallyNot: (NMBMatcher) -> Void {
        return { matcher in
            self.expectValue.toEventuallyNot(
                from(objcMatcher: matcher),
                timeout: self._timeout,
                description: nil
            )
        }
    }

    @objc public var toEventuallyNotWithDescription: (NMBMatcher, String) -> Void {
        return { matcher, description in
            self.expectValue.toEventuallyNot(
                from(objcMatcher: matcher),
                timeout: self._timeout,
                description: description
            )
        }
    }

    @objc public var toNotEventually: (NMBMatcher) -> Void {
        return toEventuallyNot
    }

    @objc public var toNotEventuallyWithDescription: (NMBMatcher, String) -> Void {
        return toEventuallyNotWithDescription
    }

    @objc public var toNever: (NMBMatcher) -> Void {
        return { matcher in
            self.expectValue.toNever(
                from(objcMatcher: matcher),
                until: self._timeout,
                description: nil
            )
        }
    }

    @objc public var toNeverWithDescription: (NMBMatcher, String) -> Void {
        return { matcher, description in
            self.expectValue.toNever(
                from(objcMatcher: matcher),
                until: self._timeout,
                description: description
            )
        }
    }

    @objc public var neverTo: (NMBMatcher) -> Void {
        return toNever
    }

    @objc public var neverToWithDescription: (NMBMatcher, String) -> Void {
        return toNeverWithDescription
    }

    @objc public var toAlways: (NMBMatcher) -> Void {
        return { matcher in
            self.expectValue.toAlways(
                from(objcMatcher: matcher),
                until: self._timeout,
                description: nil
            )
        }
    }

    @objc public var toAlwaysWithDescription: (NMBMatcher, String) -> Void {
        return { matcher, description in
            self.expectValue.toAlways(
                from(objcMatcher: matcher),
                until: self._timeout,
                description: description
            )
        }
    }

    @objc public var alwaysTo: (NMBMatcher) -> Void {
        return toAlways
    }

    @objc public var alwaysToWithDescription: (NMBMatcher, String) -> Void {
        return toAlwaysWithDescription
    }

    @objc public class func failWithMessage(_ message: String, file: FileString, line: UInt) {
        fail(message, location: SourceLocation(fileID: "Unknown/\(file)", filePath: file, line: line, column: 0))
    }
}

#endif

#endif // #if !os(WASI)
