//
//  PieceArray+.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 14/11/22.
//

import Foundation

public extension Array where Element == Piece {
    mutating func move(fromIdx: Int, toIdx: Int) {
        self[toIdx] = self[fromIdx]
        self[fromIdx] = Piece()
    }
}
