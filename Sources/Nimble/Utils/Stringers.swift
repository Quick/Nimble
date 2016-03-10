import Foundation


internal func identityAsString(value: AnyObject?) -> String {
    if let value = value {
        return NSString(format: "<%p>", unsafeBitCast(value, Int.self)).description
    } else {
        return "nil"
    }
}

internal func classAsString(cls: AnyClass) -> String {
#if _runtime(_ObjC)
    return NSStringFromClass(cls)
#else
    return String(cls)
#endif
}

internal func arrayAsString<T>(items: [T], joiner: String = ", ") -> String {
    return items.reduce("") { accum, item in
        let prefix = (accum.isEmpty ? "" : joiner)
        return accum + prefix + "\(stringify(item))"
    }
}

#if _runtime(_ObjC)
@objc internal protocol NMBStringer {
    func NMB_stringify() -> String
}

extension NSArray : NMBStringer {
    func NMB_stringify() -> String {
        let str = self.componentsJoinedByString(", ")
        return "[\(str)]"
    }
}
#endif

/// A type with a customized test output text representation.
///
/// This textual representation is produced when values will be
/// printed in test runs, and may be useful when producing
/// error messages in custom matchers.
///
/// - SeeAlso: `CustomDebugStringConvertible`
public protocol Stringifiable {
    var stringify: String { get }
}

extension Double: Stringifiable {
    public var stringify: String {
        // These are using `NSString(format:)` instead of 
        // `String(format:)` because the latter somehow breaks
        // the travis CI build on linux.
        return NSString(format: "%0.4f", self).description
    }
}

extension Float: Stringifiable {
    public var stringify: String {
        return NSString(format: "%0.4f", self).description
    }
}

extension NSNumber: Stringifiable {
    public var stringify: String {
        return NSString(format: "%0.4f", self.doubleValue).description
    }
}

extension Array: Stringifiable {
    public var stringify: String {
        let list = self.map(Nimble.stringify).joinWithSeparator(", ")
        return "[\(list)]"
    }
}

extension NSArray: Stringifiable {
    public var stringify: String {
        return self.description
    }
}

extension String: Stringifiable {
    public var stringify: String {
        return self
    }
}

extension NSData: Stringifiable {
    public var stringify: String {
        #if os(Linux)
            // FIXME: Swift on Linux triggers a segfault when calling NSData's hash() (last checked on 03-11-16)
            return "NSData<length=\(self.length)>"
        #else
            return "NSData<hash=\(self.hash),length=\(self.length)>"
        #endif
    }
}

///
/// Returns a string appropriate for displaying in test output
/// from the provided value.
///
/// - parameter value: A value that will show up in a test's output.
///
/// - returns: The string that is returned can be
///     customized per type by conforming a type to the `Stringifiable`
///     protocol. When stringifying a non-`Stringifiable` type, this
///     function will return the value's debug description and then its
///     normal description if available and in that order. Otherwise it
///     will return the result of constructing a string from the value.
///
/// - SeeAlso: `Stringifiable`
@warn_unused_result
public func stringify<T>(value: T) -> String {
    if let value = value as? Stringifiable {
        return value.stringify
    }
    
    if let value = value as? CustomDebugStringConvertible {
        return value.debugDescription
    }
    
    return String(value)
}

/// -SeeAlso: `stringify<T>(value: T)`
@warn_unused_result
public func stringify<T>(value: T?) -> String {
    if let unboxed = value {
        return stringify(unboxed)
    }
    return "nil"
}
