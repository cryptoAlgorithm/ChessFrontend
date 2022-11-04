//
//  ChessView.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import SwiftUI

struct ChessView: View {
    @EnvironmentObject private var board: BoardState

    @State private var draggingIdx: Int?

    var body: some View {
        LazyVGrid(
            columns: [GridItem](repeating: GridItem(.flexible(minimum: 50, maximum: 100), spacing: 0), count: 8),
            spacing: 0
        ) {
            ForEach(Array(board.boardState.enumerated()), id: \.offset) { idx, piece in
                PieceView(
                    item: piece,
                    bgAccented: !(idx + Int(floor(Double(idx)/8.0))).isMultiple(of: 2)
                ) {
                    draggingIdx = idx
                } dropped: {
                    guard let draggingIdx = draggingIdx else { return false }
                    withAnimation {
                        if piece.type != .empty {
                            board.boardState[idx] = Piece()
                        }
                        board.boardState.swapAt(draggingIdx, idx)
                    }
                    
                    return true
                }
            }
        }
        // This isn't redundant - it allows the window to scale properly
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}

struct ChessView_Previews: PreviewProvider {
    static var previews: some View {
        ChessView()
    }
}
