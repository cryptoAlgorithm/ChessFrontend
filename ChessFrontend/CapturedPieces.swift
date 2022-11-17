//
//  CapturedPieces.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 17/11/22.
//

import SwiftUI

/// A horizontal stack displaying the number of each type of piece captured by the player
struct CapturedPieces: View {
    let pieces: [Piece]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(PieceType.allCases.sorted { $0.points > $1.points }, id: \.self) { type in
                let matchingPieces = pieces.filter { $0.type == type }
                let count = matchingPieces.count
                if count > 0 {
                    HStack(spacing: 2) {
                        PieceImage(piece: matchingPieces[0]).frame(width: 24)
                        Text(count.description)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .help("\(matchingPieces[0].type.rawValue.capitalized)s captured: \(count)")
                    .padding(.trailing, 6)
                    .padding(.leading, 2)
                    .background(.gray.opacity(0.05))
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.init(nsColor: .separatorColor), lineWidth: 1)
                    )
                }
            }
        }
    }
}

struct CapturedPieces_Previews: PreviewProvider {
    static var previews: some View {
        CapturedPieces(pieces: [
            Piece(.pawn, side: .white),
            Piece(.king, side: .white),
            Piece(.rook, side: .white),
            Piece(.pawn, side: .white),
            Piece(.bishop, side: .white)
        ])
    }
}
