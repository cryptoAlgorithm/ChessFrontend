//
//  ChessFrontendApp.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 3/11/22.
//

import SwiftUI

internal let engine: EngineHandler! = try? EngineHandler(binaryURL: Bundle.main.url(forResource: "stockfish", withExtension: "")!)

/// The main app entrypoint when running normally
struct ChessFrontendApp: App {
    @State private var initError: String?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationTitle("Chess (real)")
                .onReceive(NotificationCenter.default.publisher(for: .engineProcTerminated)) { _ in
                    initError = "Stockfish process terminated unexpectedly"
                }
                .onAppear {
                    if engine == nil {
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
                // Force the app to be in dark theme and introduce light theme support later,
                // calling it a new "feature"
                .environment(\.colorScheme, .dark)
        }
        .windowToolbarStyle(.unifiedCompact)
    }
}
