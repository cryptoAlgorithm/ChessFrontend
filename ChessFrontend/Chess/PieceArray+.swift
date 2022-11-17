//
//  PieceArray+.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 14/11/22.
//

import Foundation

/// An alias for a board array - an array with pieces
typealias Board = Array<Piece>

public extension Array where Element == Piece {
    /// Length of each side of the board
    static let boardSize = 8

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

    /// Reset the board to the state of an initial chess board
    mutating func reset() {
        let pawns = [PieceType](repeating: .pawn, count: Board.boardSize)
        // Construct the board state from the standard initial chess board
        // This doesn't scale properly when boardSize is increased
        self = Self.defaultSetup.map { Piece($0, side: .black) }
            + pawns.map { Piece($0, side: .black) }
            // Don't use the repeating constructor so the empty pieces have unique IDs
            + (0..<Board.boardSize*(Board.boardSize - 4)).map { _ in Piece() } // 4 rows of empty squares
            + pawns.map { Piece($0, side: .white) }
            + Self.defaultSetup.map { Piece($0, side: .white) }
    }

    /// Executes a move in the board
    mutating func move(with move: Move) -> Piece? {
        let prevPiece = self[move.to.boardIdx].type != .empty ? self[move.to.boardIdx] : nil
        self[move.to.boardIdx] = self[move.from.boardIdx]
        self[move.from.boardIdx] = Piece()
        return prevPiece
    }

    /// Construct a UCI representation of the board with the specified full and half moves
    func getUCI(currentSide: PieceSide, fullMoves: Int, halfMoves: Int) -> String {
        var emptySpaces = 0
        var fenPieces = ""
        for (idx, piece) in self.enumerated() {
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
                guard idx + 1 != self.count else { break }
                fenPieces += "/"
            }
        }
        // Currently doesn't handle castling, en passant and halfmoves
        return "\(fenPieces) \(currentSide.rawValue.first!.lowercased()) - - 0 \(fullMoves)"
    }

    /// Load
    mutating func load(uci: String) {
        
    }
}
