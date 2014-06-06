import Foundation

// Not ideal, but it will work for now
func beTrue() -> PartialMatcher<Bool, _Equal<Bool>> {
    return equalTo(true)
}
