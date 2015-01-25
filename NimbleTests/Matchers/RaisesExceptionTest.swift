import XCTest
import Nimble

class RaisesExceptionTest: XCTestCase {
    var exception = NSException(name: "laugh", reason: "Lulz", userInfo: ["key": "value"])

    func testPositiveMatchesInAutoClosure() {
        expect(exception.raise()).to(raiseException())
        expect(exception.raise()).to(raiseException(named: "laugh"))
        expect(exception.raise()).to(raiseException(named: "laugh", reason: "Lulz"))
        expect(exception.raise()).to(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]))
    }

    func testPositiveMatchesInInExplicitClosure() {
        expect {
            self.exception.raise()
        }.to(raiseException())

        expect {
            self.exception.raise()
        }.to(raiseException(named: "laugh"))


        expect {
            self.exception.raise()
        }.to(raiseException(named: "laugh", reason: "Lulz"))


        expect {
            self.exception.raise()
        }.to(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]))
    }

    func testNegativeMatches() {
        failsWithErrorMessage("expected to raise exception named <foo>") {
            expect(self.exception.raise()).to(raiseException(named: "foo"))
        }

        failsWithErrorMessage("expected to raise exception named <laugh> with reason <bar>") {
            expect(self.exception.raise()).to(raiseException(named: "laugh", reason: "bar"))
        }

        failsWithErrorMessage("expected to raise exception named <laugh> with reason <Lulz> and userInfo <{k = v;}>") {
            expect(self.exception.raise()).to(raiseException(named: "laugh", reason: "Lulz", userInfo: ["k": "v"]))
        }

        failsWithErrorMessage("expected to raise any exception") {
            expect(self.exception).to(raiseException())
        }
        failsWithErrorMessage("expected to not raise any exception") {
            expect(self.exception.raise()).toNot(raiseException())
        }
        failsWithErrorMessage("expected to raise exception named <laugh> with reason <Lulz>") {
            expect(self.exception).to(raiseException(named: "laugh", reason: "Lulz"))
        }

        failsWithErrorMessage("expected to raise exception named <bar> with reason <Lulz>") {
            expect(self.exception.raise()).to(raiseException(named: "bar", reason: "Lulz"))
        }
        failsWithErrorMessage("expected to not raise exception named <laugh>") {
            expect(self.exception.raise()).toNot(raiseException(named: "laugh"))
        }
        failsWithErrorMessage("expected to not raise exception named <laugh> with reason <Lulz>") {
            expect(self.exception.raise()).toNot(raiseException(named: "laugh", reason: "Lulz"))
        }
        failsWithErrorMessage("expected to not raise exception named <laugh> with reason <Lulz> and userInfo <{key = value;}>") {
            expect(self.exception.raise()).toNot(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]))
        }
    }
}
