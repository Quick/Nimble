import Foundation

struct ObjCMatcherWrapper : Matcher {
    let matcher: KICMatcher
    let to: String
    let toNot: String

    func matches(actualExpression: Expression<NSObject?>, failureMessage: FailureMessage) -> Bool {
        failureMessage.to = to
        let pass = matcher.matches(({ actualExpression.evaluate() }), failureMessage: failureMessage, location: actualExpression.location)
        return pass
    }

    func doesNotMatch(actualExpression: Expression<NSObject?>, failureMessage: FailureMessage) -> Bool {
        failureMessage.to = toNot
        let pass = matcher.matches(({ actualExpression.evaluate() }), failureMessage: failureMessage, location: actualExpression.location)
        return !pass
    }
}

// Equivalent to Expectation, but simplified for ObjC objects only
class KICExpectation : NSObject {
    let _actualBlock: () -> NSObject!
    var _negative: Bool
    let _file: String
    let _line: Int
    var _timeout: NSTimeInterval = 1.0

    init(actualBlock: () -> NSObject!, negative: Bool, file: String, line: Int) {
        self._actualBlock = actualBlock
        self._negative = negative
        self._file = file
        self._line = line
    }

    var withTimeout: (NSTimeInterval) -> KICExpectation {
        return ({ timeout in self._timeout = timeout
            return self
        })
    }

    var to: (matcher: KICMatcher) -> Void {
        return ({(matcher: KICMatcher) -> Void in
            expect(file: self._file, line: self._line){ self._actualBlock() as NSObject? }.to(
                ObjCMatcherWrapper(matcher: matcher, to: "to", toNot: "to not")
            )
        })
    }

    var toNot: (matcher: KICMatcher) -> Void {
        return ({(matcher: KICMatcher) -> Void in
            expect(file: self._file, line: self._line){ self._actualBlock() as NSObject? }.toNot(
                ObjCMatcherWrapper(matcher: matcher, to: "to", toNot: "to not")
            )
        })
    }

    var notTo: (matcher: KICMatcher) -> Void { return toNot }

    var toEventually: (matcher: KICMatcher) -> Void {
        return ({(matcher: KICMatcher) -> Void in
            expect(file: self._file, line: self._line){ self._actualBlock() as NSObject? }.toEventually(
                ObjCMatcherWrapper(matcher: matcher, to: "to", toNot: "to not"),
                timeout: self._timeout
            )
        })
    }

    var toEventuallyNot: (matcher: KICMatcher) -> Void {
        return ({(matcher: KICMatcher) -> Void in
            expect(file: self._file, line: self._line){ self._actualBlock() as NSObject? }.toEventuallyNot(
                ObjCMatcherWrapper(matcher: matcher, to: "to", toNot: "to not"),
                timeout: self._timeout
            )
        })
    }
}

@objc class KICObjCMatcher : KICMatcher {
    let _matcher: (actualExpression: () -> NSObject?, failureMessage: FailureMessage, location: SourceLocation) -> Bool
    init(matcher: (actualExpression: () -> NSObject?, failureMessage: FailureMessage, location: SourceLocation) -> Bool) {
        self._matcher = matcher
    }

    func matches(actualExpression: () -> NSObject?, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        return _matcher(
            actualExpression: actualExpression,
            failureMessage: failureMessage,
            location: location)
    }
}

