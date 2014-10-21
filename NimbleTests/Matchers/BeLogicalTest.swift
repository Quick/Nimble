import XCTest
import Nimble

enum ConvertsToBool : BooleanType, Printable {
    case TrueLike, FalseLike

    var boolValue : Bool {
        switch self {
        case .TrueLike: return true
        case .FalseLike: return false
        }
    }

    var description : String {
        switch self {
        case .TrueLike: return "TrueLike"
        case .FalseLike: return "FalseLike"
        }
    }
}

class BeTruthyTest : XCTestCase {
    func testShouldMatchTrue() {
        expect(true).to(beTruthy())

        failsWithErrorMessage("expected <true> to not be truthy") {
            expect(true).toNot(beTruthy())
        }
    }

    func testShouldNotMatchFalse() {
        expect(false).toNot(beTruthy())

        failsWithErrorMessage("expected <false> to be truthy") {
            expect(false).to(beTruthy())
        }
    }

    func testShouldNotMatchNilBools() {
        expect(nil as Bool?).toNot(beTruthy())

        failsWithErrorMessage("expected <nil> to be truthy") {
            expect(nil as Bool?).to(beTruthy())
        }
    }

    func testShouldMatchBoolConvertibleTypesThatConvertToTrue() {
        expect(ConvertsToBool.TrueLike).to(beTruthy())

        failsWithErrorMessage("expected <TrueLike> to not be truthy") {
            expect(ConvertsToBool.TrueLike).toNot(beTruthy())
        }
    }

    func testShouldNotMatchBoolConvertibleTypesThatConvertToFalse() {
        expect(ConvertsToBool.FalseLike).toNot(beTruthy())

        failsWithErrorMessage("expected <FalseLike> to be truthy") {
            expect(ConvertsToBool.FalseLike).to(beTruthy())
        }
    }
}

class BeTrueTest : XCTestCase {
    func testShouldMatchTrue() {
        expect(true).to(beTrue())

        failsWithErrorMessage("expected <true> to not be true") {
            expect(true).toNot(beTrue())
        }
    }

    func testShouldNotMatchFalse() {
        expect(false).toNot(beTrue())

        failsWithErrorMessage("expected <false> to be true") {
            expect(false).to(beTrue())
        }
    }

    func testShouldNotMatchNilBools() {
        expect(nil as Bool?).toNot(beTrue())

        failsWithErrorMessage("expected <nil> to be true") {
            expect(nil as Bool?).to(beTrue())
        }
    }
}

class BeFalsyTest : XCTestCase {
    func testShouldNotMatchTrue() {
        expect(true).toNot(beFalsy())

        failsWithErrorMessage("expected <true> to be falsy") {
            expect(true).to(beFalsy())
        }
    }

    func testShouldMatchFalse() {
        expect(false).to(beFalsy())

        failsWithErrorMessage("expected <false> to not be falsy") {
            expect(false).toNot(beFalsy())
        }
    }

    func testShouldMatchNilBools() {
        expect(nil as Bool?).to(beFalsy())

        failsWithErrorMessage("expected <nil> to not be falsy") {
            expect(nil as Bool?).toNot(beFalsy())
        }
    }
}

class BeFalseTest : XCTestCase {
    func testShouldNotMatchTrue() {
        expect(true).toNot(beFalse())

        failsWithErrorMessage("expected <true> to be false") {
            expect(true).to(beFalse())
        }
    }

    func testShouldMatchFalse() {
        expect(false).to(beFalse())

        failsWithErrorMessage("expected <false> to not be false") {
            expect(false).toNot(beFalse())
        }
    }

    func testShouldNotMatchNilBools() {
        failsWithErrorMessage("expected <nil> to be false") {
            expect(nil as Bool?).to(beFalse())
        }

        failsWithErrorMessage("expected <nil> to not be false") {
            expect(nil as Bool?).toNot(beFalse())
        }
    }
}
