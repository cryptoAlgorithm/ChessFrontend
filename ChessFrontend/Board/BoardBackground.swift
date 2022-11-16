//
//  BoardBackground.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 16/11/22.
//

import SwiftUI

struct BoardBackground: View {
    var body: some View {
        LazyVGrid(
            columns: [GridItem](
                repeating: GridItem(.flexible(minimum: 50, maximum: 100), spacing: 0),
                count: Board.boardSize
            ),
            spacing: 0
        ) {
            ForEach(0..<Board.boardSize*Board.boardSize, id: \.self) { idx in
                Rectangle()
                    .fill(
                        (idx + idx/Board.boardSize).isMultiple(of: 2)
                            ? Color("BoardNeutral")
                            : .accentColor
                    )
                    .aspectRatio(1, contentMode: .fill)
            }
        }
    }
}

struct BoardBackground_Previews: PreviewProvider {
    static var previews: some View {
        BoardBackground()
    }
}
