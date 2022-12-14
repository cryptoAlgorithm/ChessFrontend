//
//  ChessView.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import SwiftUI

/// Renders a grid of chess pieces in a chess board-like layout
struct ChessView: View {
    @EnvironmentObject private var board: BoardViewModel

    let moveDisabled: Bool

    @State private var draggingIdx: Int?

    var body: some View {
        ZStack {
            BoardBackground()
            LazyVGrid(
                columns: [GridItem](
                    repeating: GridItem(.flexible(minimum: 50, maximum: 100), spacing: 0),
                    count: Board.boardSize
                ),
                spacing: 0
            ) {
                ForEach(Array(board.board.enumerated()), id: \.element.id) { idx, piece in
                    PieceView(item: piece) {
                        draggingIdx = idx
                    } dropped: {
                        guard let draggingIdx = draggingIdx else { return false }
                        guard idx != draggingIdx else { return false }
                        guard !moveDisabled else { return false }
                        withAnimation {
                            board.makeMove(from: draggingIdx, to: idx)
                        }
                        return true
                    }
                }
            }
        }
        // This isn't redundant - it allows the window to scale properly
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

fileprivate struct MockChessPreviewContainer: View {
    @StateObject private var previewBoard = BoardViewModel()

    var body: some View {
        ChessView(moveDisabled: false)
            .environmentObject(previewBoard)
            .onAppear {
                previewBoard.engineReadyInit()
            }
    }
}

struct ChessView_Previews: PreviewProvider {
    static var previews: some View {
        MockChessPreviewContainer()
    }
}
