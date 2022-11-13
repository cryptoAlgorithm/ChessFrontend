//
//  ChessView.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import SwiftUI

/// Renders a grid of chess pieces in a chess board-like layout
struct ChessView: View {
    @EnvironmentObject private var board: BoardState

    @State private var draggingIdx: Int?

    var body: some View {
        LazyVGrid(
            columns: [GridItem](
                repeating: GridItem(.flexible(minimum: 50, maximum: 100), spacing: 0),
                count: BoardState.boardSize
            ),
            spacing: 0
        ) {
            ForEach(Array(board.boardState.enumerated()), id: \.element.id) { idx, piece in
                PieceView(
                    item: piece,
                    bgAccented: !(idx + Int(floor(Double(idx)/Double(BoardState.boardSize)))).isMultiple(of: 2)
                ) {
                    draggingIdx = idx
                } dropped: {
                    guard let draggingIdx = draggingIdx else { return false }
                    guard idx != draggingIdx else { return false }
                    withAnimation {
                        board.makeMove(from: draggingIdx, to: idx)
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
