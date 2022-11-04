//
//  PieceDropDelegate.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 4/11/22.
//

import SwiftUI

extension PieceView: DropDelegate {
    func validateDrop(info: DropInfo) -> Bool {
        //Allow the drop to begin with any String set as the NSItemProvider
        return info.hasItemsConforming(to: [""])
    }
    
    // MARK: Drop UI State
    func dropEntered(info: DropInfo) {
        hovered = true
    }
    func dropExited(info: DropInfo) {
        hovered = false
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
