import XCTest
import Nimble

private func nonThrowingInt() -> Int {
    return 1
}

private func throwingInt() throws -> Int {
    return 1
}

private func nonThrowingAsyncInt() async -> Int {
    return 1
}

private func throwingAsyncInt() async throws -> Int {
    return 1
}

final class DSLTest: XCTestCase {
    func testExpectAutoclosureNonThrowing() throws {
        let _: SyncExpectation<Int> = expect(1)
        let _: SyncExpectation<Int> = expect(nonThrowingInt())
    }

    func testExpectAutoclosureThrowing() throws {
        let _: SyncExpectation<Int> = expect(try throwingInt())
    }

    func testExpectClosure() throws {
        let _: SyncExpectation<Int> = expect { 1 }
        let _: SyncExpectation<Int> = expect { nonThrowingInt() }
        let _: SyncExpectation<Int> = expect { try throwingInt() }
        let _: SyncExpectation<Int> = expect { () -> Int in 1 }
        let _: SyncExpectation<Int> = expect { () -> Int? in 1 }
        let _: SyncExpectation<Int> = expect { () -> Int? in nil }

        let _: SyncExpectation<Void> = expect { }
        let _: SyncExpectation<Void> = expect { () -> Void in }

        let _: SyncExpectation<Void> = expect { return }
        let _: SyncExpectation<Void> = expect { () -> Void in return }

        let _: SyncExpectation<Void> = expect { return () }
        let _: SyncExpectation<Void> = expect { () -> Void in return () }
    }

    func testExpectAsyncClosure() async throws {
        let _: AsyncExpectation<Int> = await expect { 1 }
        let _: AsyncExpectation<Int> = await expect { await nonThrowingAsyncInt() }
        let _: AsyncExpectation<Int> = await expect { try await throwingAsyncInt() }
        let _: AsyncExpectation<Int> = await expect { () -> Int in 1 }
        let _: AsyncExpectation<Int> = await expect { () -> Int? in 1 }
        let _: AsyncExpectation<Int> = await expect { () -> Int? in nil }

        let _: AsyncExpectation<Void> = await expect { }
        let _: AsyncExpectation<Void> = await expect { () -> Void in }

        let _: AsyncExpectation<Void> = await expect { return }
        let _: AsyncExpectation<Void> = await expect { () -> Void in return }

        let _: AsyncExpectation<Void> = await expect { return () }
        let _: AsyncExpectation<Void> = await expect { () -> Void in return () }
    }

    func testExpectCombinedSyncAndAsyncExpects() async throws {
        await expect { await nonThrowingAsyncInt() }.to(equal(1))
        expect(1).to(equal(1))

        expect { nonThrowingInt() }.to(equal(1))
    }
}
