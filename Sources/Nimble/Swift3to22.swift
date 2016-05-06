import Foundation
import XCTest

#if os(Linux)
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
