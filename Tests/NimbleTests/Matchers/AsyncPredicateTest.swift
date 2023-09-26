import Foundation
import XCTest
import Nimble
#if SWIFT_PACKAGE
import NimbleSharedTestHelpers
#endif

private func beCalled(times: UInt) -> AsyncMatcher<CallCounter> {
    AsyncMatcher.define { expression in
        let message = ExpectationMessage.expectedActualValueTo("be called \(times) times")
        if let value = try await expression.evaluate()?.callCount {
            return MatcherResult(bool: value == times, message: message)
        } else {
            return MatcherResult(status: .fail, message: message.appendedBeNilHint())
        }
    }
}

private actor CallCounter {
    var callCount: UInt = 0

    func call() {
        callCount += 1
    }
}

private func asyncFunction<T: Equatable>(value: T) async -> T { return value }

final class AsyncMatcherTest: XCTestCase {
    func testAsyncMatchersWithAsyncExpectations() async {
        await expecta(await asyncFunction(value: 1)).to(asyncEqual(1))
    }

    func testAsyncMatchersWithSyncExpectations() async {
        let subject = CallCounter()
        await subject.call()
        await expects(subject).to(beCalled(times: 1))
    }

#if !os(WASI)
    func testAsyncPollingWithAsyncMatchers() async {
        let subject = CallCounter()

        await expect {
            await subject.call()
            return subject
        }.toEventually(beCalled(times: 3))

        await expect {
            await asyncFunction(value: 1)
        }.toEventuallyNot(asyncEqual(0))

        await expect { await asyncFunction(value: 1) }.toNever(asyncEqual(0))
        await expect { await asyncFunction(value: 1) }.toAlways(asyncEqual(1))
    }

    func testSyncPollingWithAsyncMatchers() async {
        await expects(1).toEventually(asyncEqual(1))
        await expects(1).toAlways(asyncEqual(1))
        await expects(1).toEventuallyNot(asyncEqual(0))
        await expects(1).toNever(asyncEqual(0))
    }
#endif
}
