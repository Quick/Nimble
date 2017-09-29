//
//  CwlCatchExceptionTests.swift
//  CwlPreconditionTesting
//
//  Created by Matt Gallagher on 11/2/16.
//  Copyright © 2016 Matt Gallagher ( http://cocoawithlove.com ). All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import XCTest
import CwlCatchException
#if SWIFT_PACKAGE
import CwlCatchExceptionSupport
#endif

class TestException: NSException {
	static var name: String = "com.cocoawithlove.TestException"
	init() {
		super.init(name: NSExceptionName(rawValue: TestException.name), reason: nil, userInfo: nil)
	}
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

class CatchExceptionTests: XCTestCase {
	func testCatchException() {
	#if arch(x86_64)
		// Test catching an assertion failure
		var reachedPoint1 = false
		var reachedPoint2 = false
		let exception1: TestException? = TestException.catchException {
			// Must invoke this block
			reachedPoint1 = true
			
			// Exception raised
			TestException().raise()

			// Exception must be thrown so that this point is never reached
			reachedPoint2 = true
		}
		// We must get a valid BadInstructionException
		XCTAssert(exception1 != nil)
		XCTAssert(reachedPoint1)
		XCTAssert(!reachedPoint2)
		
		// Test without catching an assertion failure
		var reachedPoint3 = false
		var reachedPoint4 = false
		var reachedPoint5 = false
		var exception3: TestException? = nil
		let exception4: NSException? = NSException.catchException {
			exception3 = TestException.catchException {
				// Must invoke this block
				reachedPoint3 = true
				NSException(name: NSExceptionName.rangeException, reason: nil, userInfo: nil).raise()
				reachedPoint4 = true
			}
			reachedPoint5 = true
		}
		// We must not get a BadInstructionException without an assertion
		XCTAssert(exception4 != nil)
		XCTAssert(exception3 == nil)
		XCTAssert(reachedPoint3)
		XCTAssert(!reachedPoint4)
		XCTAssert(!reachedPoint5)
	#endif
	}
}
