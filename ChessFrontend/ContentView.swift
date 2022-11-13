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
        ZStack {
            HStack(spacing: 0) {
                VStack {
                    Spacer()
                    Text("You").font(.largeTitle).fontWeight(.black)
                }
                .padding(24)
                .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)
                ChessView()
                    .frame(width: 500)
                    .fixedSize()
                    .padding(.vertical, 16)
                    .background(Rectangle().fill(.red.opacity(0.4)).scaleEffect(1.05).blur(radius: 40))
                VStack(alignment: .trailing) {
                    Spacer()
                    Text(String(describing: board.moves))
                    Text("Bot").font(.largeTitle).fontWeight(.black)
                }
                .padding(24)
                .frame(minWidth: 200, maxWidth: .infinity, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
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

                Button {
                    gameOptionsPresented = false
                } label: {
                    Text("Ok").frame(maxWidth: .infinity)
                }.controlSize(.large).buttonStyle(.borderedProminent)
            }.padding(16)
        }
    }
}
