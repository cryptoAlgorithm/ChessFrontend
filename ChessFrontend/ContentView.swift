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
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Spacer()
                GroupBox {
                    if board.moves.isEmpty {
                        Text("No moves yet").font(.caption).frame(maxWidth: .infinity)
                    } else {
                        ScrollView {
                            Text(board.moves.map { $0.description }.joined(separator: ", "))
                                .font(.monospaced(.body)())
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }.frame(maxHeight: 100)
                    }
                } label: {
                    Label("Move History", systemImage: "arrowshape.turn.up.backward.badge.clock")
                }
                if board.currentSide == .black {
                    Text("Making move...")
                }
                Text("Bot").font(.largeTitle).fontWeight(.black)
            }
            .padding(24)
            .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)

            ChessView(moveDisabled: board.currentSide == .black)
                .frame(width: 500)
                .fixedSize()
                .padding(.vertical, 16)
                .background(Rectangle().fill(.red.opacity(0.4)).scaleEffect(1.07).blur(radius: 56))

            VStack(alignment: .trailing) {
                Spacer()
                if board.currentSide == .white {
                    Text("Your turn")
                }
                Text("You").font(.largeTitle).fontWeight(.black)
            }
            .padding(24)
            .frame(minWidth: 200, maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .environmentObject(board)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation { board.resetBoard() }
                    gameOptionsPresented = true
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
