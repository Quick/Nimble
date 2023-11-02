# CwlCatchException

A simple Swift wrapper around an Objective-C `@try`/`@catch` statement that selectively catches Objective-C exceptions by `NSException` subtype, rethrowing if any caught exception is not the expected subtype.

Look at [CwlCatchExceptionTests.swift](https://github.com/mattgallagher/CwlCatchException/blob/master/Tests/CwlCatchExceptionTests/CwlCatchExceptionTests.swift) for syntax.

## Requirements

From version 2.0.0-beta.1, building CwlCatchException requires Swift 5 or newer, Swift Package Manager or CocoaPods.

For use with older versions of Swift or other package managers, [use version 1.2.0 or older](https://github.com/mattgallagher/CwlCatchException/tree/1.2.0).

## Adding to your project

### Swift Package Manager

Add the following to the `dependencies` array in your "Package.swift" file:

	 .package(url: "https://github.com/mattgallagher/CwlCatchException.git", from: Version("2.0.0"))

Or by adding `https://github.com/mattgallagher/CwlCatchException.git`, version 2.0.0 or later, to the list of Swift packages for any project in Xcode.

### CocoaPods

CocoaPods is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate CwlCatchException into your Xcode project using CocoaPods, specify it in your Podfile:

pod 'CwlCatchException', '~> 2.0'

## Thanks

Includes contributions from @alexbaev, @dnkoutso and @ejensen.