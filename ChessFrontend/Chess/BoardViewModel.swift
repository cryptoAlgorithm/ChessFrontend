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
class BoardViewModel: ObservableObject {
    /// Flattened array of the current board state
    @Published public var board: [Piece] = []
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

    /// Length of each side of the board
    static public let boardSize = 8

    /// Default state of one player's pieces
    private static let defaultSetup: [PieceType] = [
        .rook,
        .knight,
        .bishop,
        .queen,
        .king,
        .bishop,
        .knight,
        .rook
    ]

    /// Get the FEN representation of the board
    ///
    /// This doesn't currently produce a fully valid FEN string, only one that's sufficient to satisfy
    /// the needs of Stockfish.
    public var fen: String {
        var emptySpaces = 0
        var fenPieces = ""
        for (idx, piece) in board.enumerated() {
            if piece.type == .empty {
                emptySpaces += 1
            } else {
                if emptySpaces != 0 {
                    fenPieces += String(emptySpaces)
                    emptySpaces = 0
                }
                let pieceName = piece.type.rawValue.first!
                fenPieces += piece.side == .white ? pieceName.uppercased() : pieceName.lowercased()
            }
            if (idx+1) % Self.boardSize == 0 {
                if emptySpaces != 0 {
                    fenPieces += String(emptySpaces)
                    emptySpaces = 0
                }
                // Don't append a trailing /
                guard idx + 1 != board.count else { break }
                fenPieces += "/"
            }
        }
        // Currently doesn't handle castling, en passant and halfmoves
        return "\(fenPieces) \(currentSide.rawValue.first!.lowercased()) - - 0 \(fullMoves)"
    }

    /// Reset the board to an initial state
    public func resetBoard() {
        let pawns = [PieceType](repeating: .pawn, count: Self.boardSize)
        // Construct the board state from the standard initial chess board
        // This doesn't scale properly when boardSize is increased
        board = Self.defaultSetup.map { Piece($0, side: .black) }
            + pawns.map { Piece($0, side: .black) }
            // Don't use the repeating constructor so the empty pieces have unique IDs
            + (0..<Self.boardSize*(Self.boardSize - 4)).map { _ in Piece() } // 4 rows of empty squares
            + pawns.map { Piece($0, side: .white) }
            + Self.defaultSetup.map { Piece($0, side: .white) }
        // Reset moves
        moves = []
        currentSide = .white
        // Reset scores
        mateMoves = nil
        score = 0

        Task {
            // Tell the engine we are starting a new game
            try await ChessFrontendApp.engine!.newGame()
            try await ChessFrontendApp.engine!.waitReady()
        }
    }

    /// Make a move by moving a piece at an index in the board array to another position
    @MainActor public func makeMove(from: Int, to: Int) {
        moves.append(Move(fromBoardIdx: from, toBoardIdx: to))
        board.move(fromIdx: from, toIdx: to)
        currentSide.invert()
        playAIMove()
    }

    /// If it's the AI's turn, play the AI's move
    @MainActor public func playAIMove() {
        // Black is always the AI side
        guard currentSide == .black else { return }
        Task {
            try await ChessFrontendApp.engine!.updatePosition(fen: fen)
            // Force-unwrap because we shouldn't have gotten here if the engine couldn't be init
            let infos = try await ChessFrontendApp.engine!.search(depth: searchDepth)
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
