//
//  PieceView.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import SwiftUI

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
            .fill(bgAccented ? Color.accentColor : .gray)
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

// MARK: - Piece drop delegate
extension PieceView: DropDelegate {
    func validateDrop(info: DropInfo) -> Bool {
        //Allow the drop to begin with any String set as the NSItemProvider
        print("validate drop")
        return info.hasItemsConforming(to: [PieceView.pieceUT])
    }
    
    // MARK: Drop UI State
    func dropEntered(info: DropInfo) {
        print("drop entered!")
       // dragOver = true
    }
    func dropExited(info: DropInfo) {
       // dragOver = false
    }
    
    // MARK: Drop and Save
    func performDrop(info: DropInfo) -> Bool {
        /*if let task = draggedTask {
         return true
         }else{
         return false
         }*/
        return false
    }
}
