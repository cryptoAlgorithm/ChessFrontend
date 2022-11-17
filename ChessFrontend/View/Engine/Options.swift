//
//  Options.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 15/11/22.
//

import SwiftUI

struct Options: View {
    let options: [UCIResponse.Option]

    private func persistAndUpdateOption<Value: LosslessStringConvertible>(_ name: String, value: Value) async throws {
        try await engine.setOptionValue(name, value: value.description)
    }

    var body: some View {
        ForEach(options) { elem in
            if case .spin(name: let name, default: let def, min: let min, max: let max) = elem {
                Knob(name: name, def: def, min: min, max: max) { newValue in
                    try await persistAndUpdateOption(name, value: newValue)
                }
            } else if case .check(name: let name, default: let def) = elem {
                Check(name: name, def: def) { newValue in
                    try await persistAndUpdateOption(name, value: newValue)
                }
            }
        }
    }
}
