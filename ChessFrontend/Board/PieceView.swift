//
//  PieceView.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import SwiftUI

/// A single square on the chess board
///
/// This view is designed to be as "dumb" as possible to reduce impact during renders.
struct PieceView: View {
    let item: Piece
    let bgAccented: Bool
    let dragged: () -> Void
    let dropped: () -> Bool

    @State var dragOver = false

    /// UTI of a chess piece used for drag and drop
    private static let pieceUT = "com.cryptoalgo.chessPiece"

    var itemImage: some View {
        Group {
            if item.type != .empty, let side = item.side {
                Image("Pieces/\(side.rawValue)/\(item.type)").resizable().scaledToFit()
            } else { EmptyView() }
        }
    }

    var body: some View {
        Rectangle()
            .fill(bgAccented ? Color.accentColor : .init("BoardNeutral"))
            .overlay { itemImage }
            .overlay {
                if dragOver {
                    Rectangle().strokeBorder(.blue, lineWidth: 4)
                } else { EmptyView() }
            }
            .aspectRatio(1, contentMode: .fit)
            .onDrag(if: item.type != .empty) {
                dragged()
                return NSItemProvider(
                    item: NSString(utf8String: item.type.rawValue),
                    typeIdentifier: Self.pieceUT
                )
            } preview: { itemImage }
            .onDrop(of: [Self.pieceUT], isTargeted: $dragOver, perform: { providers in
                dropped()
            })
    }
}

struct BoardItemView_Previews: PreviewProvider {
    static var previews: some View {
        PieceView(item: Piece(.pawn, side: .white), bgAccented: true) {
            
        } dropped: {
            false
        }
    }
}
