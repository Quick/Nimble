import Foundation

struct ObjCMatcherWrapper : Matcher {
    let matcher: NMBMatcher
    let to: String
    let toNot: String

    func matches(actualExpression: Expression<NSObject>, failureMessage: FailureMessage) -> Bool {
        failureMessage.to = to
        return matcher.matches(({ actualExpression.evaluate() }), failureMessage: failureMessage, location: actualExpression.location)
    }

    func doesNotMatch(actualExpression: Expression<NSObject>, failureMessage: FailureMessage) -> Bool {
        failureMessage.to = toNot
        return matcher.doesNotMatch(({ actualExpression.evaluate() }), failureMessage: failureMessage, location: actualExpression.location)
    }
}

// Equivalent to Expectation, but simplified for ObjC objects only
public class NMBExpectation : NSObject {
    let _actualBlock: () -> NSObject!
    var _negative: Bool
    let _file: String
    let _line: UInt
    var _timeout: NSTimeInterval = 1.0

    public init(actualBlock: () -> NSObject!, negative: Bool, file: String, line: UInt) {
        self._actualBlock = actualBlock
        self._negative = negative
        self._file = file
        self._line = line
    }

    public var withTimeout: (NSTimeInterval) -> NMBExpectation {
        return ({ timeout in self._timeout = timeout
            return self
        })
    }

    public var to: (matcher: NMBMatcher) -> Void {
        return ({ matcher in
            expect(file: self._file, line: self._line){ self._actualBlock() as NSObject? }.to(
                ObjCMatcherWrapper(matcher: matcher, to: "to", toNot: "to not")
            )
        })
    }

    public var toNot: (matcher: NMBMatcher) -> Void {
        return ({ matcher in
            expect(file: self._file, line: self._line){ self._actualBlock() as NSObject? }.toNot(
                ObjCMatcherWrapper(matcher: matcher, to: "to", toNot: "to not")
            )
        })
    }

    public var notTo: (matcher: NMBMatcher) -> Void { return toNot }

    public var toEventually: (matcher: NMBMatcher) -> Void {
        return ({ matcher in
            expect(file: self._file, line: self._line){ self._actualBlock() as NSObject? }.toEventually(
                ObjCMatcherWrapper(matcher: matcher, to: "to", toNot: "to not"),
                timeout: self._timeout
            )
        })
    }

    public var toEventuallyNot: (matcher: NMBMatcher) -> Void {
        return ({ matcher in
            expect(file: self._file, line: self._line){ self._actualBlock() as NSObject? }.toEventuallyNot(
                ObjCMatcherWrapper(matcher: matcher, to: "to", toNot: "to not"),
                timeout: self._timeout
            )
        })
    }
}

@objc public class NMBObjCMatcher : NMBMatcher {
    let _match: (actualExpression: () -> NSObject?, failureMessage: FailureMessage, location: SourceLocation) -> Bool
    let _doesNotMatch: (actualExpression: () -> NSObject?, failureMessage: FailureMessage, location: SourceLocation) -> Bool

    init(matcher: (actualExpression: () -> NSObject?, failureMessage: FailureMessage, location: SourceLocation) -> Bool) {
        self._match = matcher
        self._doesNotMatch = ({ actualExpression, failureMessage, location in
            return !matcher(actualExpression: actualExpression, failureMessage: failureMessage, location: location)
        })
    }

    init(matcher: (actualExpression: () -> NSObject?, failureMessage: FailureMessage, location: SourceLocation, shouldNotMatch: Bool) -> Bool) {
        self._match = ({ actualExpression, failureMessage, location in
            return matcher(actualExpression: actualExpression, failureMessage: failureMessage, location: location, shouldNotMatch: false)
        })
        self._doesNotMatch = ({ actualExpression, failureMessage, location in
            return matcher(actualExpression: actualExpression, failureMessage: failureMessage, location: location, shouldNotMatch: true)
        })
    }

    init(matcher: (actualExpression: () -> NSObject?, failureMessage: FailureMessage, location: SourceLocation) -> Bool,
        doesNotMatch: (actualExpression: () -> NSObject?, failureMessage: FailureMessage, location: SourceLocation) -> Bool) {
        self._match = matcher
        self._doesNotMatch = doesNotMatch
    }

    public func matches(actualBlock: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        return _match(
            actualExpression: ({ actualBlock() as NSObject? }),
            failureMessage: failureMessage,
            location: location)
    }

    public func doesNotMatch(actualBlock: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        return _doesNotMatch(
            actualExpression: ({ actualBlock() as NSObject? }),
            failureMessage: failureMessage,
            location: location)

    }
}

