//
//  ChessFrontendApp.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import SwiftUI

struct ChessFrontendApp: App {
    static let engine = try? StockfishHandler()

    @State private var initError: String?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationTitle("Chess (real)")
                .onReceive(NotificationCenter.default.publisher(for: .stockfishProcTerminated)) { _ in
                    initError = "Stockfish process terminated unexpectedly"
                }
                .onAppear {
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
