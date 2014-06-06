import Foundation

// Not ideal, but it will work for now
func beFalsy() -> PartialMatcher<Bool, _Equal<Bool>> {
    return equalTo(false)
}