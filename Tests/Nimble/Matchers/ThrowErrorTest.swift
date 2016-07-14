import XCTest
import Nimble

enum Error : ErrorProtocol {
    case laugh
    case cry
}

enum EquatableError : ErrorProtocol {
    case parameterized(x: Int)
}

extension EquatableError : Equatable {
}

func ==(lhs: EquatableError, rhs: EquatableError) -> Bool {
    switch (lhs, rhs) {
    case (.parameterized(let l), .parameterized(let r)):
        return l == r
    }
}

enum CustomDebugStringConvertibleError : ErrorProtocol {
    case a
    case b
}

extension CustomDebugStringConvertibleError : CustomDebugStringConvertible {
    var debugDescription : String {
        return "code=\(_code)"
    }
}

final class ThrowErrorTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (ThrowErrorTest) -> () throws -> Void)] {
        return [
            ("testPositiveMatches", testPositiveMatches),
            ("testPositiveMatchesWithClosures", testPositiveMatchesWithClosures),
            ("testNegativeMatches", testNegativeMatches),
            ("testPositiveNegatedMatches", testPositiveNegatedMatches),
            ("testNegativeNegatedMatches", testNegativeNegatedMatches),
            ("testNegativeMatchesDoNotCallClosureWithoutError", testNegativeMatchesDoNotCallClosureWithoutError),
            ("testNegativeMatchesWithClosure", testNegativeMatchesWithClosure),
        ]
    }

    func testPositiveMatches() {
        expect { throw Error.laugh }.to(throwError())
        expect { throw Error.laugh }.to(throwError(Error.laugh))
        expect { throw Error.laugh }.to(throwError(errorType: Error.self))
        expect { throw EquatableError.parameterized(x: 1) }.to(throwError(EquatableError.parameterized(x: 1)))
    }

    func testPositiveMatchesWithClosures() {
        // Generic typed closure
        expect { throw EquatableError.parameterized(x: 42) }.to(throwError { error in
            guard case EquatableError.parameterized(let x) = error else { fail(); return }
            expect(x) >= 1
        })
        // Explicit typed closure
        expect { throw EquatableError.parameterized(x: 42) }.to(throwError { (error: EquatableError) in
            guard case .parameterized(let x) = error else { fail(); return }
            expect(x) >= 1
        })
        // Typed closure over errorType argument
        expect { throw EquatableError.parameterized(x: 42) }.to(throwError(errorType: EquatableError.self) { error in
            guard case .parameterized(let x) = error else { fail(); return }
            expect(x) >= 1
        })
        // Typed closure over error argument
        expect { throw Error.laugh }.to(throwError(Error.laugh) { (error: Error) in
            expect(error._domain).to(beginWith("Nim"))
        })
        // Typed closure over error argument
        expect { throw Error.laugh }.to(throwError(Error.laugh) { (error: Error) in
            expect(error._domain).toNot(beginWith("as"))
        })
    }

    func testNegativeMatches() {
        // Same case, different arguments
        failsWithErrorMessage("expected to throw error <parameterized(2)>, got <parameterized(1)>") {
            expect { throw EquatableError.parameterized(x: 1) }.to(throwError(EquatableError.parameterized(x: 2)))
        }
        // Same case, different arguments
        failsWithErrorMessage("expected to throw error <parameterized(2)>, got <parameterized(1)>") {
            expect { throw EquatableError.parameterized(x: 1) }.to(throwError(EquatableError.parameterized(x: 2)))
        }
        // Different case
        failsWithErrorMessage("expected to throw error <cry>, got <laugh>") {
            expect { throw Error.laugh }.to(throwError(Error.cry))
        }
        // Different case with closure
        failsWithErrorMessage("expected to throw error <cry> that satisfies block, got <laugh>") {
            expect { throw Error.laugh }.to(throwError(Error.cry) { _ in return })
        }
        // Different case, implementing CustomDebugStringConvertible
        failsWithErrorMessage("expected to throw error <code=1>, got <code=0>") {
            expect { throw CustomDebugStringConvertibleError.a }.to(throwError(CustomDebugStringConvertibleError.b))
        }
    }

    func testPositiveNegatedMatches() {
        // No error at all
        expect { return }.toNot(throwError())
        // Different case
        expect { throw Error.laugh }.toNot(throwError(Error.cry))
    }

    func testNegativeNegatedMatches() {
        // No error at all
        failsWithErrorMessage("expected to not throw any error, got <laugh>") {
            expect { throw Error.laugh }.toNot(throwError())
        }
        // Different error
        failsWithErrorMessage("expected to not throw error <laugh>, got <laugh>") {
            expect { throw Error.laugh }.toNot(throwError(Error.laugh))
        }
    }

    func testNegativeMatchesDoNotCallClosureWithoutError() {
        failsWithErrorMessage("expected to throw error that satisfies block, got no error") {
            expect { return }.to(throwError { error in
                fail()
            })
        }
        
        failsWithErrorMessage("expected to throw error <laugh> that satisfies block, got no error") {
            expect { return }.to(throwError(Error.laugh) { error in
                fail()
            })
        }
    }

    func testNegativeMatchesWithClosure() {
#if SWIFT_PACKAGE
        let moduleName = "NimbleTestSuite"
#else
        let moduleName = "NimbleTests"
#endif
        let innerFailureMessage = "expected to equal <foo>, got <\(moduleName).Error>"
        let closure = { (error: Error) in
            print("** In closure! With domain \(error._domain)")
            expect(error._domain).to(equal("foo"))
        }

        failsWithErrorMessage([innerFailureMessage, "expected to throw error from type <Error> that satisfies block, got <laugh>"]) {
            expect { throw Error.laugh }.to(throwError(closure: closure))
        }

        failsWithErrorMessage([innerFailureMessage, "expected to throw error <laugh> that satisfies block, got <laugh>"]) {
            expect { throw Error.laugh }.to(throwError(Error.laugh, closure: closure))
        }
    }
}
