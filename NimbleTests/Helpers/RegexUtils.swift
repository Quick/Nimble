import Foundation

extension NSCharacterSet {
    public class func specialRegularExpressionCharacterSet() -> NSCharacterSet {
        return NSCharacterSet(charactersInString: "[\\^$.|?*+(){}")
    }
}

extension String {
    public func stringByEscapingSpecialRegularExpressionCharacters() -> String {
        let regexCharset = NSCharacterSet.specialRegularExpressionCharacterSet()
        return self.unicodeScalars.map { c -> String in
            let charAsString = String(c)
            if regexCharset.longCharacterIsMember(c.value) {
                return "\\" + charAsString
            } else {
                return charAsString
            }
        }.joinWithSeparator("")
    }

    public func escapedRegularExpressionWithAddressToken() throws -> NSRegularExpression {
        let pattern = self.stringByEscapingSpecialRegularExpressionCharacters()
                          .stringByReplacingOccurrencesOfString("%addr%", withString: "[0-9a-fx]+")
        return try NSRegularExpression(pattern: pattern, options: [])
    }
}
