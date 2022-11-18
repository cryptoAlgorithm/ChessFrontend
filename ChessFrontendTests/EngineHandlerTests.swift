//
//  EngineHandlerTests.swift
//  ChessFrontendTests
//
//  Created by Vincent Kwok on 18/11/22.
//

import XCTest
import ChessFrontend

final class EngineHandlerTests: XCTestCase {
    private static let binaryName = "stockfish-universal"
    private var binaryURL: URL? {
        Bundle.main.url(forResource: Self.binaryName, withExtension: "")
    }

    func testBinaryExists() throws {
        XCTAssertNotNil(binaryURL)
    }

    func testInfo() async throws {
        let readyExpectation = XCTNSNotificationExpectation(name: .engineReady)

        let engine = try EngineHandler(with: binaryURL!)
        wait(for: [readyExpectation], timeout: 0.5)

        XCTAssertNotNil(engine.engineAuthor, "engineAuthor should not be nil after engine initialisation")
        XCTAssertNotNil(engine.engineName, "engineName should not be nil after engine initialisation")
        // Assert that some basic options are present
        XCTAssertTrue(engine.options.contains { $0.name == "Threads" }, "The Threads option should be present")
        XCTAssertTrue(engine.options.contains { $0.name == "Ponder" }, "The Ponder option should be present")
    }
}
