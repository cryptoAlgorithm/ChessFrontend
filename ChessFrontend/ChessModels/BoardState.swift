//
//  BoardState.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import Foundation

/// Stores and synchronises the state of the board throughout the app
class BoardState: ObservableObject {
    /// Flattened array of the current board state
    @Published public var boardState: [Piece] = []
    /// Move history of both players
    @Published public var moves: [Move] = []

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

    /// Reset the board to an initial state
    public func resetBoard() {
        let pawns = [PieceType](repeating: .pawn, count: Self.boardSize)
        boardState = Self.defaultSetup.map { Piece($0, side: .black) }
            + pawns.map { Piece($0, side: .black) }
            + [Piece](repeating: Piece(), count: Self.boardSize*(Self.boardSize - 4)) // 4 rows of empty squares
            + pawns.map { Piece($0, side: .white) }
            + Self.defaultSetup.map { Piece($0, side: .white) }
    }

    public func makeMove(from: Int, to: Int) {
        //if piece.type != .empty {
            //board.boardState[idx] = Piece()
        //}
        moves.append(Move(fromBoardIdx: from, toBoardIdx: to))
        boardState[to] = boardState[from]
        boardState[from] = Piece()
    }

    init() {
        resetBoard()
    }
}
