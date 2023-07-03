//
//  BoardState.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import SwiftUI

/// Stores and synchronises the state of the board throughout the app
///
/// This also essentially acts as a view model for ``ContentView``
public class BoardViewModel: ObservableObject {
    /// Flattened array of the current board state
    @Published public var board: [Piece] = []
    /// Pieces that were removed by the white player
    @Published public var whiteRemovedPieces: [Piece] = []
    /// Pieces that were removed by the black player
    @Published public var blackRemovedPieces: [Piece] = []

    /// Move history of both players
    @Published public var moves: [Move] = []

    /// Side that will make the next move
    @Published public var currentSide: PieceSide = .white

    /// Number of "full moves" - incremented after every black move
    @Published public var fullMoves = 1

    /// Advantage of the white player over the black player, in pawns
    ///
    /// > A negative score indicates that the black player has an advantage.
    @Published public var score = 0.0
    /// Number of moves to a mate
    ///
    /// > A positive number indicates the engine can mate the player in a certain number of moves,
    /// > while a negative score indicates the player can mate the player in a certain number of moves.
    @Published public var mateMoves: Int?

    /// Depth to use when searching for a move
    @Published public var searchDepth = 20

    /// If the underlying Stockfish engine is ready
    @Published public var engineReady = false

    /// Get the FEN representation of the board
    ///
    /// This doesn't currently produce a fully valid FEN string, only one that's sufficient to satisfy
    /// the needs of Stockfish.
    public var fen: String {
        board.getUCI(currentSide: currentSide, fullMoves: fullMoves, halfMoves: 0)
    }

    /// Reset the board to an initial state
    public func resetBoard() {
        board.reset()
        blackRemovedPieces.removeAll()
        whiteRemovedPieces.removeAll()
        // Reset moves
        moves = []
        currentSide = .white
        // Reset scores
        mateMoves = nil
        score = 0

        Task {
            // Tell the engine we are starting a new game
            try await engine.newGame()
            try await engine.waitReady()
        }
    }

    /// Make a move by moving a piece at an index in the board array to another position
    @MainActor public func makeMove(from: Int, to: Int) {
        let move = Move(fromBoardIdx: from, toBoardIdx: to)
        // Make sure this is a valid move first
        let (validMoves, captures) = board.validMoves(for: from)
        guard validMoves.contains(move) || captures.contains(move) else {
            return
        }
        moves.append(move)
        if let removedPiece = board.move(with: moves.last!) {
            if removedPiece.side == .white { blackRemovedPieces.append(removedPiece) }
            else { whiteRemovedPieces.append(removedPiece) }
        }
        currentSide.invert()
        playAIMove()
    }

    /// If it's the AI's turn, play the AI's move
    @MainActor public func playAIMove() {
        // Black is always the AI side
        guard currentSide == .black else { return }
        Task {
            try await engine.updatePosition(moves: moves)
            // Force-unwrap because we shouldn't have gotten here if the engine couldn't be init
            let infos = try await engine.search(depth: searchDepth)
            print("updated moves")
            for info in infos {
                if case .bestMove(let bestMove) = info {
                    withAnimation {
                        makeMove(from: bestMove.move.from.boardIdx, to: bestMove.move.to.boardIdx)
                    }
                    print("best move: \(bestMove)")
                }
            }
            fullMoves += 1
        }
    }

    /// Initialises the base board state, should be called only after the engine is ready
    @MainActor func engineReadyInit() {
        currentSide = .white
        resetBoard()
        engineReady = true
    }
}
