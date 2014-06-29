import Foundation

func _identityAsString(value: NSObject?) -> String {
    if !value {
        return "nil"
    }
    var str: String
    let args = VaListBuilder()
    args.append(value!.description)
    args.append(value!)
    str = NSString(format: "<%@> (0x%p)", arguments: args.va_list())
    return str
}

func _arrayAsString<T>(items: T[], joiner: String = ", ") -> String {
    return items.reduce("") { accum, item in
        let prefix = (accum.isEmpty ? "" : joiner)
        return accum + prefix + "\(item)"
    }
}
