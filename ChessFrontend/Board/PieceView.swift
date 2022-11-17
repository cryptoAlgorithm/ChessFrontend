//
//  PieceView.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import SwiftUI

struct PieceImage: View {
    let piece: Piece
    
    @Environment(\.controlSize) private var size: ControlSize

    var body: some View {
        if piece.type != .empty, let side = piece.side {
            Image("Pieces/\(side.rawValue)/\(piece.type)")
                .resizable()
                .scaledToFit()
        } else {
            Rectangle().fill(.clear)
        }
    }
}

/// A single square on the chess board
///
/// This view is designed to be as "dumb" as possible to reduce impact during renders.
struct PieceView: View {
    let item: Piece
    let dragged: () -> Void
    let dropped: () -> Bool

    @State var dragOver = false

    /// UTI of a chess piece used for drag and drop
    private static let pieceUT = "com.cryptoalgo.chessPiece"

    var body: some View {
        PieceImage(piece: item)
            .overlay {
                if dragOver {
                    Rectangle().strokeBorder(.blue, lineWidth: 4)
                } else { EmptyView() }
            }
            .aspectRatio(1, contentMode: .fit)
            .onDrag(if: item.type != .empty && item.side == .white) {
                dragged()
                return NSItemProvider(
                    item: NSString(utf8String: item.type.rawValue),
                    typeIdentifier: Self.pieceUT
                )
            }
            .onDrop(of: [Self.pieceUT], isTargeted: $dragOver, perform: { providers in
                dropped()
            })
    }
}

struct BoardItemView_Previews: PreviewProvider {
    static var previews: some View {
        PieceView(item: Piece(.pawn, side: .white)) {
            
        } dropped: {
            false
        }
    }
}
