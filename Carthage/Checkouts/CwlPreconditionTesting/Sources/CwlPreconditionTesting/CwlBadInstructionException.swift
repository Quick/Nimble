//
//  CwlBadInstructionException.swift
//  CwlPreconditionTesting
//
//  Created by Matt Gallagher on 2016/01/10.
//  Copyright © 2016 Matt Gallagher ( https://www.cocoawithlove.com ). All rights reserved.
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

#if (os(macOS) || os(iOS)) && (arch(x86_64) || arch(arm64))

import Foundation

#if SWIFT_PACKAGE
	import CwlMachBadInstructionHandler
#endif

var raiseBadInstructionException = {
	BadInstructionException().raise()
} as @convention(c) () -> Void

/// A simple NSException subclass. It's not required to subclass NSException (since the exception type is represented in the name) but this helps for identifying the exception through runtime type.
@objc(BadInstructionException)
public class BadInstructionException: NSException {
	static var name: String = "com.cocoawithlove.BadInstruction"
	
	init() {
		super.init(name: NSExceptionName(rawValue: BadInstructionException.name), reason: nil, userInfo: nil)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	/// An Objective-C callable function, invoked from the `mach_exc_server` callback function `catch_mach_exception_raise_state` to push the `raiseBadInstructionException` function onto the stack.
	@objc(receiveReply:)
	public class func receiveReply(_ reply: bad_instruction_exception_reply_t) -> CInt {
		let old_state = UnsafeRawPointer(reply.old_state!).bindMemory(to: NativeThreadState.self, capacity: 1)
		let old_stateCnt: mach_msg_type_number_t = reply.old_stateCnt
		let new_state = UnsafeMutableRawPointer(reply.new_state!).bindMemory(to: NativeThreadState.self, capacity: 1)
		let new_stateCnt: UnsafeMutablePointer<mach_msg_type_number_t> = reply.new_stateCnt!
		
		// Make sure we've been given enough memory
		guard
			old_stateCnt == nativeThreadStateCount,
			new_stateCnt.pointee >= nativeThreadStateCount
		else {
			return KERN_INVALID_ARGUMENT
		}
		
		// 0. Copy over the state.
		new_state.pointee = old_state.pointee
		
#if arch(x86_64)
		// 1. Decrement the stack pointer
		new_state.pointee.__rsp -= UInt64(MemoryLayout<Int>.size)
		
		// 2. Save the old Instruction Pointer to the stack.
		guard let pointer = UnsafeMutablePointer<UInt64>(bitPattern: UInt(new_state.pointee.__rsp)) else {
			return KERN_INVALID_ARGUMENT
		}
		pointer.pointee = old_state.pointee.__rip
				
		// 3. Set the Instruction Pointer to the new function's address
		new_state.pointee.__rip = unsafeBitCast(raiseBadInstructionException, to: UInt64.self)
		
#elseif arch(arm64)
		// 1. Set the link register to the current address.
		new_state.pointee.__lr = old_state.pointee.__pc
		
		// 2. Set the Instruction Pointer to the new function's address.
		new_state.pointee.__pc = unsafeBitCast(raiseBadInstructionException, to: UInt64.self)
#endif

		new_stateCnt.pointee = nativeThreadStateCount
		
		return KERN_SUCCESS
	}
}

#endif
