import Foundation
import XCTest

#if !swift(>=3)
    public typealias Boolean = BooleanType
    public typealias Collection = CollectionType
    public typealias ErrorProtocol = ErrorType

    internal func unsafeBitCast<T, U>(x: T, to: U.Type) -> U {
        return unsafeBitCast(x, to)
    }

    typealias NSFastEnumerationIterator = NSFastGenerator

    extension NSObjectProtocol {
        internal func isKind(of aClass: Swift.AnyClass) -> Bool {
            return isKindOfClass(aClass)
        }

        internal func isMember(of aClass: Swift.AnyClass) -> Bool {
            return isMemberOfClass(aClass)
        }
    }

    public protocol Sequence: SequenceType {
        associatedtype Iterator: GeneratorType = Generator
    }

    extension Sequence {
        internal func makeIterator() -> Iterator {
            return generate() as! Iterator
        }

        internal func enumerated() -> EnumerateSequence<Self> {
            return enumerate()
        }

        internal func sorted(@noescape isOrderedBefore isOrderedBefore: (Generator.Element, Generator.Element) -> Bool) -> [Generator.Element] {
            return sort(isOrderedBefore)
        }
    }

    extension Sequence where Iterator.Element: Equatable {
        internal func contains(element: Iterator.Element) -> Bool {
            for case let item as Iterator.Element in self where item == element {
                return true
            }
            return false
        }
    }

    extension Sequence where Generator.Element == String {
        internal func joined(separator separator: String) -> String {
            return joinWithSeparator(separator)
        }
    }

    extension AnySequence: Sequence {}
    extension Array: Sequence {}
    extension Dictionary: Sequence {}
    extension Set: Sequence {}


    extension XCTestCase {
        @nonobjc internal func recordFailure(withDescription description: String, inFile filePath: String, atLine lineNumber: UInt, expected: Bool) {
            recordFailureWithDescription(description, inFile: filePath, atLine: lineNumber, expected: expected)
        }
    }

#endif

#if !swift(>=3) || os(Linux)
    extension NSCharacterSet {
        internal class func whitespacesAndNewlines() -> NSCharacterSet {
            return whitespaceAndNewlineCharacterSet()
        }
    }

    extension NSComparisonResult {
        internal static var orderedAscending: NSComparisonResult { return .OrderedAscending }
        internal static var orderedSame: NSComparisonResult { return .OrderedSame }
        internal static var orderedDescending: NSComparisonResult { return .OrderedDescending }
    }

    extension NSDateFormatter {
        internal func string(from date: NSDate) -> String {
            return stringFromDate(date)
        }
    }

    extension NSMutableArray {
        internal func add(_ anObject: AnyObject) {
            addObject(anObject)
        }
        internal func componentsJoined(by separator: String) -> String {
            return componentsJoinedByString(separator)
        }
    }

    extension NSNotificationCenter {
        internal func addObserver(forName name: String?, object obj: AnyObject?, queue: NSOperationQueue?, using block: (NSNotification) -> Swift.Void) -> NSObjectProtocol {
            return addObserverForName(name, object: obj, queue: queue, usingBlock: block)
        }
    }

    extension NSNumber {
        internal convenience init(value: Double) {
            self.init(double:value)
        }
        internal convenience init(value: Float) {
            self.init(float:value)
        }
    }

    extension NSRunLoop {
        internal class func current() -> NSRunLoop {
            return currentRunLoop()
        }
        internal func run(mode: String, before limitDate: NSDate) -> Bool {
            return runMode(mode, beforeDate: limitDate)
        }
    }

    extension NSString {
        internal func components(separatedBy separator: String) -> [String] {
            return componentsSeparatedByString(separator)
        }
        internal func range(of searchString: String) -> NSRange {
            return rangeOfString(searchString)
        }
        internal func trimmingCharacters(in set: NSCharacterSet) -> String {
            return stringByTrimmingCharactersInSet(set)
        }
    }

    extension NSStringCompareOptions {
        internal static var caseInsensitiveSearch: NSStringCompareOptions { return .CaseInsensitiveSearch }
        internal static var literalSearch: NSStringCompareOptions { return .LiteralSearch }
        internal static var backwardsSearch: NSStringCompareOptions { return .BackwardsSearch }
        internal static var anchoredSearch: NSStringCompareOptions { return .AnchoredSearch }
        internal static var numericSearch: NSStringCompareOptions { return .NumericSearch }
        @available(OSX 10.5, *)
        internal static var diacriticInsensitiveSearch: NSStringCompareOptions { return .DiacriticInsensitiveSearch }
        @available(OSX 10.5, *)
        internal static var widthInsensitiveSearch: NSStringCompareOptions { return .WidthInsensitiveSearch }
        @available(OSX 10.5, *)
        internal static var forcedOrderingSearch: NSStringCompareOptions { return .ForcedOrderingSearch }
        @available(OSX 10.7, *)
        internal static var regularExpressionSearch: NSStringCompareOptions { return .RegularExpressionSearch }
    }

    extension NSThread {
        internal class func current() -> NSThread {
            return currentThread()
        }
    }

    extension String {
        internal func contains(_ other: String) -> Bool {
            return containsString(other)
        }
        internal func range(of aString: String, options mask: NSStringCompareOptions = [], range searchRange: Range<Index>? = nil, locale: NSLocale? = nil) -> Range<Index>? {
            return rangeOfString(aString, options: mask, range: searchRange, locale: locale)
        }
    }
#endif
