//
//  Launcher.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 12/11/22.
//

import SwiftUI

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

struct TestApp: App {
    var body: some Scene {
        WindowGroup { Text("Unit testing") }
    }
}
