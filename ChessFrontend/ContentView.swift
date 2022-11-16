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
    @State private var advancedOptionsVisible = false
    @State private var engineOptions: [UCIResponse.Option] = []

    @StateObject private var board = BoardViewModel()

    private var engineSidebar: some View {
        VStack(alignment: .leading, spacing: 8) {
            GroupBox {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Search depth:").font(.callout)
                    // Don't use a stepped slider since there would be way too many steps
                    Slider(value: .convert(from: $board.searchDepth), in: 1...30) {
                        Text(String(format: "%02d", board.searchDepth)).font(.monospaced(.caption)())
                    }.controlSize(.small)

                    Divider().padding(.vertical, 4)

                    Button {
                        withAnimation { advancedOptionsVisible.toggle() }
                    } label: {
                        Label {
                            Text("Advanced options")
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } icon: {
                            Image(systemName: "chevron.right")
                                .rotationEffect(.degrees(advancedOptionsVisible ? 90 : 0))
                        }.contentShape(Rectangle())
                    }.buttonStyle(.plain)
                    if advancedOptionsVisible {
                        GroupBox {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("\(Image(systemName: "exclamationmark.triangle")) Don't change these options unless you know exactly what you're doing!")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                    Options(options: engineOptions)
                                    Text("Some changes will only take effect after a restart")
                                        .font(.caption)
                                }.frame(maxWidth: .infinity, alignment: .leading)
                            }.frame(height: 250)
                        }.transition(.move(edge: .bottom))
                    }
                }.padding(2)
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
        .onReceive(NotificationCenter.default.publisher(for: .stockfishCPUpdate)) { out in
            if let obj = out.object, let (score, mateIn) = obj as? (Int, Int?) {
                board.score = Double(score) / -100.0 // Convert centipawns to pawns and negate score
                board.mateMoves = mateIn
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .stockfishOptionsUpdate)) { options in
            if let options = options.object as? [UCIResponse.Option] {
                engineOptions = options
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .stockfishReady)) { _ in
            board.engineReadyInit()
        }
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
            VStack(alignment: .leading, spacing: 6) {
                Text("Game Options").font(.largeTitle).fontWeight(.bold)

                if !board.engineReady {
                    ProgressView("Waiting for engine...").controlSize(.large)
                }

                Button {
                    gameOptionsPresented = false
                } label: {
                    Text("Ok").frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .disabled(!board.engineReady)
            }
            .padding(16)
            .frame(width: 400)
        }
    }
}
