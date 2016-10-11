# CwlCatchException
A simple Swift wrapper around an Objective-C `@try`/`@catch` statement that selectively catches Objective-C exceptions by `NSException` subtype, rethrowing if any caught exception is not the expected subtype.

Look at [CwlCatchExceptionTests.swift](https://github.com/mattgallagher/CwlCatchException/blob/master/CwlCatchExceptionTests/CwlCatchExceptionTests.swift?ts=4) for usage and details.
