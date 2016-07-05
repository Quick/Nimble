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

/// A type with a customized test output text representation.
///
/// This textual representation is produced when values will be
/// printed in test runs, and may be useful when producing
/// error messages in custom matchers.
///
/// - SeeAlso: `CustomDebugStringConvertible`
public protocol TestOutputStringConvertible {
    var testDescription: String { get }
}

extension Double: TestOutputStringConvertible {
    public var testDescription: String {
        return NSNumber(double: self).testDescription
    }
}

extension Float: TestOutputStringConvertible {
    public var testDescription: String {
        return NSNumber(float: self).testDescription
    }
}

extension NSNumber: TestOutputStringConvertible {
    // This is using `NSString(format:)` instead of
    // `String(format:)` because the latter somehow breaks
    // the travis CI build on linux.
    public var testDescription: String {
        let description = self.description
        
        if description.containsString(".") {
            // Travis linux swiftpm build doesn't like casting String to NSString,
            // which is why this annoying nested initializer thing is here.
            // Maybe this will change in a future snapshot.
            let decimalPlaces = NSString(string: NSString(string: description)
                .componentsSeparatedByString(".")[1])
            
            if decimalPlaces.length > 4 {
                return NSString(format: "%0.4f", self.doubleValue).description
            }
        }
        return self.description
    }
}

extension Array: TestOutputStringConvertible {
    public var testDescription: String {
        let list = self.map(Nimble.stringify).joinWithSeparator(", ")
        return "[\(list)]"
    }
}

extension AnySequence: TestOutputStringConvertible {
    public var testDescription: String {
        let generator = self.generate()
        var strings = [String]()
        var value: AnySequence.Generator.Element?
        
        repeat {
            value = generator.next()
            if let value = value {
                strings.append(stringify(value))
            }
        } while value != nil
        
        let list = strings.joinWithSeparator(", ")
        return "[\(list)]"
    }
}

extension NSArray: TestOutputStringConvertible {
    public var testDescription: String {
        let list = Array(self).map(Nimble.stringify).joinWithSeparator(", ")
        return "(\(list))"
    }
}

extension NSIndexSet: TestOutputStringConvertible {
    public var testDescription: String {
        let list = Array(self).map(Nimble.stringify).joinWithSeparator(", ")
        return "(\(list))"
    }
}

extension String: TestOutputStringConvertible {
    public var testDescription: String {
        return self
    }
}

extension NSData: TestOutputStringConvertible {
    public var testDescription: String {
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
///     customized per type by conforming a type to the `TestOutputStringConvertible`
///     protocol. When stringifying a non-`TestOutputStringConvertible` type, this
///     function will return the value's debug description and then its
///     normal description if available and in that order. Otherwise it
///     will return the result of constructing a string from the value.
///
/// - SeeAlso: `TestOutputStringConvertible`
@warn_unused_result
public func stringify<T>(value: T) -> String {
    if let value = value as? TestOutputStringConvertible {
        return value.testDescription
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

#if _runtime(_ObjC)
@objc public class NMBStringer: NSObject {
    @warn_unused_result
    @objc public class func stringify(obj: AnyObject?) -> String {
        return Nimble.stringify(obj)
    }
}
#endif

// MARK: Collection Type Stringers

/// Attempts to generate a pretty type string for a given value. If the value is of a Objective-C
/// collection type, or a subclass thereof, (e.g. `NSArray`, `NSDictionary`, etc.). 
/// This function will return the type name of the root class of the class cluster for better
/// readability (e.g. `NSArray` instead of `__NSArrayI`).
///
/// For values that don't have a type of an Objective-C collection, this function returns the
/// default type description.
///
/// - parameter value: A value that will be used to determine a type name.
///
/// - returns: The name of the class cluster root class for Objective-C collection types, or the
/// the `dynamicType` of the value for values of any other type.
public func prettyCollectionType<T>(value: T) -> String {
    #if _runtime(_ObjC)
    // Check for types that are not in corelibs-foundation separately
    if value is NSHashTable {
        return String(NSHashTable.self)
    }
    #endif

    switch value {
    case is NSArray:
        return String(NSArray.self)
    case is NSDictionary:
        return String(NSDictionary.self)
    case is NSSet:
        return String(NSSet.self)
    case is NSIndexSet:
        return String(NSIndexSet.self)
    default:
        return String(value)
    }
}

/// Returns the type name for a given collection type. This overload is used by Swift
/// collection types.
///
/// - parameter collection: A Swift `CollectionType` value.
///
/// - returns: A string representing the `dynamicType` of the value.
public func prettyCollectionType<T: CollectionType>(collection: T) -> String {
    return String(collection.dynamicType)
}
