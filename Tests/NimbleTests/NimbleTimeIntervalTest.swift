//
//  NimbleTimeIntervalTest.swift
//  Nimble
//
//  Created by Rachel Brindle on 9/12/25.
//  Copyright © 2025 Jeff Hui. All rights reserved.
//

@testable import Nimble
import XCTest

final class NimbleTimeIntervalTest: XCTestCase {
    func testDivideLeftHandSeconds() {
        XCTAssertEqual((NimbleTimeInterval.seconds(10) / NimbleTimeInterval.seconds(3)), (10 / 3))
        XCTAssertEqual((NimbleTimeInterval.seconds(1) / NimbleTimeInterval.milliseconds(1)), 1000.0)
        XCTAssertEqual((NimbleTimeInterval.seconds(1) / NimbleTimeInterval.microseconds(100)), 10_000)
        XCTAssertEqual((NimbleTimeInterval.seconds(10) / NimbleTimeInterval.nanoseconds(200)), 50_000_000)
    }

    func testDivideLeftHandMilliseconds() {
        XCTAssertEqual((NimbleTimeInterval.milliseconds(1) / NimbleTimeInterval.seconds(1)), 0.001)
        XCTAssertEqual((NimbleTimeInterval.milliseconds(1) / NimbleTimeInterval.milliseconds(1)), 1)
        XCTAssertEqual((NimbleTimeInterval.milliseconds(1) / NimbleTimeInterval.microseconds(1)), 1_000)
        XCTAssertEqual((NimbleTimeInterval.milliseconds(1) / NimbleTimeInterval.nanoseconds(1)), 1_000_000)
    }

    func testDivideLeftHandMicroseconds() {
        XCTAssertEqual((NimbleTimeInterval.microseconds(1) / NimbleTimeInterval.seconds(1)), 0.000_001)
        XCTAssertEqual((NimbleTimeInterval.microseconds(1) / NimbleTimeInterval.milliseconds(1)), 0.001)
        XCTAssertEqual((NimbleTimeInterval.microseconds(1) / NimbleTimeInterval.microseconds(1)), 1)
        XCTAssertEqual((NimbleTimeInterval.microseconds(1) / NimbleTimeInterval.nanoseconds(1)), 1_000)
    }

    func testDivideLeftHandNanoseconds() {
        XCTAssertEqual((NimbleTimeInterval.nanoseconds(1) / NimbleTimeInterval.seconds(1)), 0.000_000_001)
        XCTAssertEqual((NimbleTimeInterval.nanoseconds(1) / NimbleTimeInterval.milliseconds(1)), 0.000_001)
        XCTAssertEqual((NimbleTimeInterval.nanoseconds(1) / NimbleTimeInterval.microseconds(1)), 0.001)
        XCTAssertEqual((NimbleTimeInterval.nanoseconds(1) / NimbleTimeInterval.nanoseconds(1)), 1)
    }
}
