import Foundation


func _identityAsString(value: NSObject?) -> String {
    if !value {
        return "nil"
    }
    return NSString(format: "<%p>", value!)
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

func stringify<S: Sequence>(value: S) -> String {
    var generator = value.generate()
    var strings = [String]()
    var value: S.GeneratorType.Element?
    do {
        value = generator.next()
        if value {
            strings.append(stringify(value))
        }
    } while value
    let str = ", ".join(strings)
    return "[\(str)]"
}

extension NSArray : NMBStringer {
    func NMB_stringify() -> String {
        let str = valueForKey("description").componentsJoinedByString(", ")
        return "[\(str)]"
    }
}

func stringify<T>(value: T?) -> String {
    if value is Double {
        return NSString(format: "%.4f", (value as Double))
    }
    return toString(value)
}

extension Optional: Printable {
    public var description: String {
        switch self {
        case let .Some(value):
            return toString(value)
        default: return "nil"
        }
    }
}
