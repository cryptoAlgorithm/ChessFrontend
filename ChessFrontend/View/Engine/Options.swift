//
//  Options.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 15/11/22.
//

import SwiftUI

struct Options: View {
    let options: [UCIResponse.Option]

    var body: some View {
        ForEach(options) { elem in
            if case .spin(name: let name, default: let def, min: let min, max: let max) = elem {
                Knob(name: name, def: def, min: min, max: max) { newValue in
                    Task { try await ChessFrontendApp.engine!.setOptionValue(name, value: String(newValue)) }
                }
            }
        }
    }
}
