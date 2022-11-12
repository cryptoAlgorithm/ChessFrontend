//
//  PieceLocation.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 12/11/22.
//

import Foundation

/// A struct to represent the location of a piece on the chess board
///
/// The top left and right of the board is a8 and h8 respectively. An ascii-art representation
/// of the chess board's layout is provided below for your convenience.
///
/// **Board layout:**
/// ```
/// |8  |   |   |   |   |   |   |   |
/// |---|---|---|---|---|---|---|---|
/// |7  |   |   |   |   |   |   |   |
/// |---|---|---|---|---|---|---|---|
/// |6  |   |   |   |   |   |   |   |
/// |---|---|---|---|---|---|---|---|
/// |5  |   |   |   |   |   |   |   |
/// |---|---|---|---|---|---|---|---|
/// |4  |   |   |   |   |   |   |   |
/// |---|---|---|---|---|---|---|---|
/// |3  |   |   |   |   |   |   |   |
/// |---|---|---|---|---|---|---|---|
/// |2  |   |   |   |   |   |   |   |
/// |---|---|---|---|---|---|---|---|
/// |1a | b | c | d | e | f | g | h |
/// ```
public struct PieceLocation {
    /// X coordinate of the piece's location (1-indexed)
    public let x: Int
    /// Y coordinate of the piece's location (1-indexed)
    public let y: Int

    /// Creates an instance of this struct from indices of the to and from locations in the flattened board array
    ///
    /// - Parameter boardIdx: Index of piece location in the flattened 1D board array (0-indexed)
    public init(boardIdx: Int) {
        x = (boardIdx % BoardState.boardSize) + 1
        y = BoardState.boardSize - boardIdx/BoardState.boardSize
    }
}

extension PieceLocation: CustomStringConvertible {
    public var description: String {
        "\(Character(charCode: Int(Unicode.Scalar("a").value) + x - 1))\(y)"
    }
}
