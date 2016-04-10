//
//  Helpers.swift
//  TaylorSource
//
//  Created by Daniel Thorpe on 03/04/2016.
//  Copyright © 2016 Daniel Thorpe. All rights reserved.
//

import XCTest

func XCTAssertThrowsError<E, T where E: ErrorType, E: Equatable>(@autoclosure expression: () throws -> T, @autoclosure _ expectedError: () -> E, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {

    var didCatchCorrectError = false

    do {
        _ = try expression()
    }
    catch let error as E where error == expectedError() {
        didCatchCorrectError = true
    }
    catch {
        XCTFail("Incorrect error type thrown: \(error)", file: file, line: line)
    }
    XCTAssertTrue(didCatchCorrectError, message, file: file, line: line)
}

func XCTAssertNoThrows<T>(@autoclosure expression: () throws -> T, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) -> T! {

    do {
        return try expression()
    }
    catch {
        XCTFail(message(), file: file, line: line)
    }
    return nil
}

struct TestError: ErrorType, Equatable {
    let uuid: String = NSUUID().UUIDString
}

func == (lhs: TestError, rhs: TestError) -> Bool {
    return lhs.uuid == rhs.uuid
}




