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
    private static let simulatedMoves = 100
    private static let searchDepth = 10 // Use a way shallower depth to quicken tests
    private var binaryURL: URL? {
        Bundle.main.url(forResource: Self.binaryName, withExtension: "")
    }

    func testBinaryExists() {
        XCTAssertNotNil(binaryURL)
    }

    private func initAndWaitForEngine() throws -> EngineHandler {
        let engine = try EngineHandler(with: binaryURL!)
        wait(for: [XCTNSNotificationExpectation(name: .engineReady)], timeout: 0.5)
        return engine
    }

    func testInfo() throws {
        let engine = try initAndWaitForEngine()

        XCTAssertNotNil(engine.engineAuthor, "engineAuthor should not be nil after engine initialisation")
        XCTAssertNotNil(engine.engineName, "engineName should not be nil after engine initialisation")
        // Assert that some basic options are present
        XCTAssertTrue(engine.options.contains { $0.name == "Threads" }, "The Threads option should be present")
        XCTAssertTrue(engine.options.contains { $0.name == "Ponder" }, "The Ponder option should be present")
    }

    func testEngineAgainstEngine() async throws {
        var moves: [Move] = []

        // Initialise engines sequentially
        let engineA = try initAndWaitForEngine()
        let engineB = try initAndWaitForEngine()

        let notTerminatingExpectation = XCTNSNotificationExpectation(name: .engineProcTerminated)
        notTerminatingExpectation.isInverted = true

        // Start new games and wait for both engines to be ready
        try await engineA.newGame()
        try await engineB.newGame()
        try await engineA.waitReady()
        try await engineB.waitReady()

        func makeMove(with responses: [UCIResponse]) {
            for move in responses {
                if case .bestMove(let bestMove) = move {
                    moves.append(bestMove.move)
                    return
                }
            }
            XCTAssertTrue(false, "A move should have been made")
        }

        for m in 0..<Self.simulatedMoves { // Simulate 100 moves
            if m.isMultiple(of: 2) {
                try await engineA.updatePosition(moves: moves)
                makeMove(with: try await engineA.search(depth: Self.searchDepth))
            } else {
                try await engineB.updatePosition(moves: moves)
                makeMove(with: try await engineB.search(depth: Self.searchDepth))
            }
        }
        XCTAssertEqual(moves.count, Self.simulatedMoves)
        wait(for: [notTerminatingExpectation], timeout: 0.1)
    }

    func testEvaluationScore() async throws {
        let engine = try initAndWaitForEngine()
        try await engine.updatePosition(moves: [])

        let scoreUpdateExpectation = XCTNSNotificationExpectation(name: .engineCPUpdate)
        scoreUpdateExpectation.handler = { notification in
            guard let score = notification.object as? (Int, Int?) else { return false }
            XCTAssertLessThan(
                abs(score.0)/100, 5,
                "Score should not have a magnitude greater than 5 pawns in the first turn"
            )
            return true
        }
        _ = try await engine.search(depth: Self.searchDepth)

        wait(for: [scoreUpdateExpectation], timeout: 10)
    }
}
