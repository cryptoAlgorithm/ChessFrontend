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
struct Move {
    /// Coordinates of the square to move from
    let from: PieceLocation

    /// Coordinates of the square to move to
    let to: PieceLocation

    /// Creates an instance of this struct from indices of the to and from locations in the flattened board array
    public init(fromBoardIdx: Int, toBoardIdx: Int) {
        from = PieceLocation(boardIdx: fromBoardIdx)
        to = PieceLocation(boardIdx: toBoardIdx)
    }
}

extension Move: CustomStringConvertible {
    var description: String { "\(from)\(to)" }
}
