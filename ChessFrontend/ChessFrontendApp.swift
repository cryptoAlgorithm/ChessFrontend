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
    static let engine = try? StockfishHandler()

    @State private var initError: String?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .toolbar(.visible, for: .windowToolbar)
                .navigationTitle("Chess (real)")
                .environmentObject(board)
                .onReceive(NotificationCenter.default.publisher(for: .stockfishProcTerminated)) { _ in
                    initError = "Stockfish process terminated unexpectedly"
                }
                .onAppear {
                    board.resetBoard()
                    if Self.engine == nil {
                        initError = "Stockfish initialisation failed"
                    }
                }
                .alert(initError ?? "", isPresented: .constant(initError != nil)) {
                    Button {
                        NSApp.terminate(nil)
                    } label: {
                        Text("Quit")
                    }
                } message: {
                    Text("This is a fatal error and cannot be dismissed")
                }
        }
        .windowToolbarStyle(.unifiedCompact)
    }
}
