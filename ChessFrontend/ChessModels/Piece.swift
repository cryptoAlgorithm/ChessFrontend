//
//  Piece.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import Foundation

struct Piece {
    let type: PieceType
    let side: PieceSide?

    init(_ type: PieceType = .empty, side: PieceSide) {
        self.type = type
        self.side = side
    }

    init() {
        type = .empty
        side = nil
    }
}

enum PieceSide: String {
    case white = "White"
    case black = "Black"
}

enum PieceType: String {
    case empty
    case pawn
    case bishop
    case knight
    case rook
    case queen
    case king
}
