import XCTest
import Tailor

class TailorRunnerComponentsTest: XCTestCase {

    override func setUp() {
        super.setUp()
        clearKnownSpecs()
        setAssertionRecorder { assertion, message, file, line in
            XCTAssert(assertion, message, file: file, line: line)
        }
    }

    func testDescribeBlock() {
        var wasDescribeCalled = false
        var wasItCalled = false
        var node = describe("tapping a button") {
            wasDescribeCalled = true
            it("should be captured") {
                wasItCalled = true
            }
        }

        expect(wasDescribeCalled).to(beTruthy())
        expect(wasItCalled).to(beFalsy())
        runSpecs(node)
        expect(wasItCalled).to(beTruthy())
    }

    func testItBlock() {
        var wasCalled = false
        var node = it("should convert the bool") {
            wasCalled = true
        }
        expect(wasCalled).to(beFalsy())
        runSpecs(node)
        expect(wasCalled).to(beTruthy())
    }
}
