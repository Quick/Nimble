#if !os(WASI)

import XCTest
import Nimble

final class AsyncAwaitTest: XCTestCase {
    func testToPositiveMatches() async {
        func someAsyncFunction() async throws -> Int {
            try await Task.sleep(nanoseconds: 1_000_000) // 1 millisecond
            return 1
        }

        await expect { try await someAsyncFunction() }.to(equal(1))
    }
}

#endif
