//
//  ContentView.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import SwiftUI

/// The app's main view
struct ContentView: View {
    @State private var gameOptionsPresented = true

    @StateObject private var board = BoardState()

    var body: some View {
        HStack {
            ChessView().padding()
            Text(String(describing: board.moves))
        }
        .environmentObject(board)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    gameOptionsPresented = true
                    board.resetBoard()
                } label: {
                    Label("Reset game", systemImage: "arrow.clockwise")
                }.help("Reset game")
            }
        }
        .sheet(isPresented: $gameOptionsPresented) {
            VStack(alignment: .leading) {
                Text("Game Options").font(.largeTitle).fontWeight(.bold)
                
                
                
                Button("ok") {
                    gameOptionsPresented = false
                }.controlSize(.large)
            }.padding(16)
        }
    }
}
