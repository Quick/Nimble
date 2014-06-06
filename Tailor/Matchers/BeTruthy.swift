import Foundation

// Not ideal, but it will work for now
func beTruthy() -> PartialMatcher<Bool, _Equal<Bool>> {
    return equalTo(true)
}
