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
                    .overlay(alignment: .topLeading) {
                        if idx.isMultiple(of: Board.boardSize) {
                            // Combining this with the bottom equation in any combination causes a type check timeout
                            let row = idx / Board.boardSize
                            Text(String(Board.boardSize - row))
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(.black.opacity(0.5))
                                .padding(2)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if idx >= Board.boardSize * (Board.boardSize-1) {
                            let xIdx = idx - Board.boardSize * (Board.boardSize-1)
                            Text(String(Character(charCode: Int(Unicode.Scalar("a").value) + xIdx)))
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(.black.opacity(0.5))
                                .padding(2)
                        }
                    }
            }
        }
    }
}

struct BoardBackground_Previews: PreviewProvider {
    static var previews: some View {
        BoardBackground()
    }
}
