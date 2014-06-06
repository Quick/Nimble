import Foundation

// Not ideal, but it will work for now
func beFalse() -> PartialMatcher<Bool, _Equal<Bool>> {
    return equalTo(false)
}