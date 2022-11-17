//
//  Piece.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import Foundation

/// A struct representing a chess piece
public struct Piece: Identifiable {
    /// The type of chess piece this struct represents
    public let type: PieceType

    /// The side this chess piece belongs to
    ///
    /// Will only be `nil` if ``Piece/type`` is ``PieceType/empty``.
    public let side: PieceSide?

    /// Unique ID identifying this piece in the chess board
    ///
    /// > This ID is only guaranteed to be unique across all pieces currently
    /// > on the chess board.
    public let id: UUID

    /// Create a chess piece of a specific type and side
    public init(_ type: PieceType, side: PieceSide) {
        self.type = type
        self.side = side
        id = UUID()
    }

    /// Create an empty chess piece
    public init() {
        type = .empty
        side = nil
        id = UUID()
    }
}

/// Which color's side this piece belongs to
public enum PieceSide: String {
    /// The piece belongs to the white side
    case white = "White"
    /// The piece belongs to the black side
    case black = "Black"

    /// Invert the current side (i.e. a black side becomes white and vice versa)
    public mutating func invert() {
        self = self == .white ? .black : .white
    }

    /// Create an instance with a random side
    public init() {
        self = Bool.random() ? .white : .black
    }
}

/// The type of chess piece that resides at a position
public enum PieceType: String, CaseIterable {
    /// No chess piece exists at the location
    case empty
    /// A pawn exists at the location
    case pawn
    /// A bishop exists at the location
    case bishop
    /// A knight exists at the location
    case knight
    /// A rook exists at the location
    case rook
    /// A queen exists at the location
    case queen
    /// A king exists at the location
    case king

    /// Number of points the piece is worth
    public var points: Int {
        switch self {
        case .empty:
            return 0
        case .pawn:
            return 1
        case .knight, .bishop:
            return 3
        case .rook:
            return 5
        case .queen:
            return 9
        case .king: // Technically the king is worth infinite points but Int.max is the closest to infinity
            return .max
        }
    }
}
