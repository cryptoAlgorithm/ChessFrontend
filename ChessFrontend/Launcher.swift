//
//  Launcher.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 12/11/22.
//

import SwiftUI

/// A dummy main struct that returns different main `App`s depending if the app is running normally or being tested
@main
struct Launcher {
    static func main() throws {
        if NSClassFromString("XCTestCase") == nil {
            ChessFrontendApp.main()
        } else {
            TestApp.main()
        }
    }
}

/// The main app entrypoint when testing
struct TestApp: App {
    var body: some Scene {
        WindowGroup { Text("Unit testing") }
    }
}
