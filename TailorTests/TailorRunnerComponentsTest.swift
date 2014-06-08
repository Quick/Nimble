import XCTest
import Tailor

class TailorBootstrap : TSSpec {
    override func spec() -> SpecBehavior! {
        return behaviors {
            describe("cheese") {
                it("should be brown") {
                    expect(1).to(equalTo(1))
                }
            }
        }
    }
}
