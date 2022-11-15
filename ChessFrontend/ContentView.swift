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

    private var engineSidebar: some View {
        VStack(alignment: .leading, spacing: 8) {
            GroupBox {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Search depth:").font(.callout)
                    // Don't use a stepped slider since there would be way too many steps
                    Slider(value: .convert(from: $board.searchDepth), in: 1...30) {
                        Text(String(format: "%02d", board.searchDepth)).font(.monospaced(.caption)())
                    }.controlSize(.small)
                }
            } label: {
                Label("Configuration", systemImage: "gearshape")
            }
            Spacer()
            if board.currentSide == .black {
                PlayerTurnPill(isBot: true).transition(.asymmetricLeadingPush)
            }
            Text("Bot").font(.largeTitle).fontWeight(.black)
        }
        .padding(16)
    }

    private var humanSidebar: some View {
        VStack(alignment: .trailing, spacing: 8) {
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
            Spacer()
            if board.currentSide == .white {
                PlayerTurnPill(isBot: false).transition(.asymmetricTrailingPush)
            }
            Text("You").font(.largeTitle).fontWeight(.black)
        }
        .padding(16)
    }

    var body: some View {
        HStack(spacing: 0) {
            engineSidebar.frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)

            ChessView(moveDisabled: board.currentSide == .black)
                .environmentObject(board)
                .frame(width: 500)
                .fixedSize()
                .padding(.vertical, 16)
                .background(Rectangle().fill(.red.opacity(0.4)).scaleEffect(1.07).blur(radius: 56))

            humanSidebar.frame(minWidth: 200, maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 16)
        .background(.black)
        .overlay(alignment: .top) {
            PlayerScoreView(score: board.score, mateIn: nil)
        }
        .onReceive(NotificationCenter.default.publisher(for: .stockfishCPUpdate), perform: { out in
            if let obj = out.object, let (score, mateIn) = obj as? (Int, Int?) {
                board.score = Double(score) / -100.0 // Convert centipawns to pawns and negate score
                board.mateMoves = mateIn
            }
        })
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
