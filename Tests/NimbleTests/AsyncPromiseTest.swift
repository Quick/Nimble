import XCTest
import Foundation
@testable import Nimble

final class AsyncPromiseTest: XCTestCase {
    func testSuspendsUntilValueIsSent() async {
        let promise = AsyncPromise<Int>()

        async let value = promise.value

        promise.send(3)

        let received = await value
        expect(received).to(equal(3))
    }

    func testIgnoresFutureValuesSent() async {
        let promise = AsyncPromise<Int>()

        promise.send(3)
        promise.send(4)

        await expecta(await promise.value).to(equal(3))
    }

    func testAllowsValueToBeBackpressured() async {
        let promise = AsyncPromise<Int>()

        promise.send(3)

        await expecta(await promise.value).to(equal(3))
    }

    func testSupportsMultipleAwaiters() async {
        let promise = AsyncPromise<Int>()

        async let values = await withTaskGroup(of: Int.self, returning: [Int].self) { taskGroup in
            for _ in 0..<10 {
                taskGroup.addTask {
                    await promise.value
                }
            }

            var values = [Int]()

            for await value in taskGroup {
                values.append(value)
            }

            return values
        }

        promise.send(4)

        let received = await values

        expect(received).to(equal(Array(repeating: 4, count: 10)))
    }
}
