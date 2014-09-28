import Foundation


func _identityAsString(value: AnyObject?) -> String {
    if value == nil {
        return "nil"
    }
    return NSString(format: "<%p>", unsafeBitCast(value!, Int.self))
}

func _arrayAsString<T>(items: [T], joiner: String = ", ") -> String {
    return items.reduce("") { accum, item in
        let prefix = (accum.isEmpty ? "" : joiner)
        return accum + prefix + "\(item)"
    }
}

@objc protocol NMBStringer {
    func NMB_stringify() -> String
}

func stringify<S: SequenceType>(value: S) -> String {
    var generator = value.generate()
    var strings = [String]()
    var value: S.Generator.Element?
    do {
        value = generator.next()
        if value != nil {
            strings.append(stringify(value))
        }
    } while value != nil
    let str = ", ".join(strings)
    return "[\(str)]"
}

extension NSArray : NMBStringer {
    func NMB_stringify() -> String {
        let str = self.componentsJoinedByString(", ")
        return "[\(str)]"
    }
}

private let optionalWithStringRegExp = NSRegularExpression.regularExpressionWithPattern(
    "^Optional\\(\"(.*)\"\\)$", options: nil, error: nil)!
private let optionalRegExp = NSRegularExpression.regularExpressionWithPattern("^Optional\\((.*)\\)$", options: nil, error: nil)!

func stripOptionalBox(description:String) -> String {
    if !description.isEmpty {
        var stripped = optionalWithStringRegExp.stringByReplacingMatchesInString(description, options: nil,
            range: NSRange(location: 0, length: description.utf16Count), withTemplate: "$1")
        stripped = optionalRegExp.stringByReplacingMatchesInString(stripped, options: nil,
            range: NSRange(location: 0, length: stripped.utf16Count), withTemplate: "$1")
        
        return stripped
    }
    return description
}


func stringify<T>(value: T) -> String {
    if value is Double {
        return NSString(format: "%.4f", (value as Double))
    }
    return stripOptionalBox(toString(value))
}

func stringify<T>(value: T?) -> String {
    if let unboxed = value {
       return stringify(unboxed)
    }
    return "nil"
}
