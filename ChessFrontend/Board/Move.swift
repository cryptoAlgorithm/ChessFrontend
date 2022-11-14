//
//  Move.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 12/11/22.
//

import Foundation

/// A struct to represent a chess move
///
/// This doesn't do any validation and is simply for the storage of moves
public struct Move {
    /// Coordinates of the square to move from
    public let from: PieceLocation

    /// Coordinates of the square to move to
    public let to: PieceLocation

    /// Creates an instance of this struct from indices of the to and from locations in the flattened board array
    public init(fromBoardIdx: Int, toBoardIdx: Int) {
        from = PieceLocation(boardIdx: fromBoardIdx)
        to = PieceLocation(boardIdx: toBoardIdx)
    }

    public init(from str: String) throws {
        from = try PieceLocation(from: String(str.prefix(2)))
        to = try PieceLocation(from: String(str.suffix(2)))
    }
}

extension Move: CustomStringConvertible {
    public var description: String { "\(from)\(to)" }
}
