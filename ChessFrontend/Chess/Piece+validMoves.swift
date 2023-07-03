//
//  Piece+validMoves.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 2/7/23.
//

import Foundation

internal extension Piece {
    private func addIfFree(moves: inout [Move], location: PieceLocation) {

    }

    /// Add moves until a certain location, either diagonally, horizontally or vertically
    private func addTo(
        from: PieceLocation, to: PieceLocation, board: Board,
        moves: inout [Move], captures: inout [Move]
    ) {
        var loc = from
        while loc != to {
            // Move one step closer to end
            if to.x > loc.x { loc.x += 1 } else if to.x < loc.x { loc.x -= 1 }
            if to.y > loc.y { loc.y += 1 } else if to.y < loc.y { loc.y -= 1 }
            let move = Move(from: from, to: loc)
            if board.piece(at: loc).type != .empty { // There's already a piece, so this is a capture
                captures.append(move)
            } else {
                moves.append(move)
            }
        }
    }

    func validMoves(at: PieceLocation, for board: Board) -> ([Move], [Move]) {
        var captures: [Move] = []
        var moves: [Move] = []
        switch type {
        case .pawn:
            addTo(
                from: at, to: .init(x: at.x, y: at.y+(side == .white ? 2 : -2)),
                board: board, moves: &moves, captures: &captures
            )

        default: break
        }
        return (moves, captures)
    }
}
