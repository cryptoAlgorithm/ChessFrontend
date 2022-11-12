//
//  PieceLocationTests.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 12/11/22.
//

import XCTest
import ChessFrontend

final class PieceLocationTests: XCTestCase {
    func testCoordinates() throws {
        let p1 = PieceLocation(boardIdx: 10)
        XCTAssertEqual(p1.x, 3)
        XCTAssertEqual(p1.y, 7)
        let p2 = PieceLocation(boardIdx: 8)
        XCTAssertEqual(p2.x, 1)
        XCTAssertEqual(p2.y, 7)
        let p3 = PieceLocation(boardIdx: 7)
        XCTAssertEqual(p3.x, 8)
        XCTAssertEqual(p3.y, 8)
    }

    func testDescription() throws {
        let p1 = PieceLocation(boardIdx: 10)
        XCTAssertEqual(p1.description, "c7")
        let p2 = PieceLocation(boardIdx: 8)
        XCTAssertEqual(p2.description, "a7")
        let p3 = PieceLocation(boardIdx: 7)
        XCTAssertEqual(p3.description, "h8")
    }
}
