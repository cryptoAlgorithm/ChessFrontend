//
//  BoardState.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import Foundation

/// Stores and synchronises the state of the board throughout the app
class BoardState: ObservableObject {
    @Published var boardState: [Piece] = []

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
        let pawns = [PieceType](repeating: .pawn, count: 8)
        boardState = Self.defaultSetup.map { Piece($0, side: .black) }
            + pawns.map { Piece($0, side: .black) }
            + [Piece](repeating: Piece(), count: 8*4) // 4 rows of empty squares
            + pawns.map { Piece($0, side: .white) }
            + Self.defaultSetup.map { Piece($0, side: .white) }
    }

    init() {
        resetBoard()
    }
}
