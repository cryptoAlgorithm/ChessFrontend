//
//  ChessFrontendApp.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import SwiftUI

@main
struct ChessFrontendApp: App {
    @StateObject private var board = BoardState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(board)
                .onAppear { board.resetBoard() }
        }
    }
}
