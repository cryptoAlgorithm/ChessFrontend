//
//  Knob.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 15/11/22.
//

import SwiftUI

struct Knob: View {
    let name: String
    let def: Int
    let min: Int
    let max: Int
    let commitValue: (Int) -> Void

    @State private var currentValue = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(name): ").font(.callout) + Text(String(currentValue)).font(.monospaced(.callout)())
            Slider(value: .convert(from: $currentValue), in: Float(min)...Float(max)) { isDragging in
                if !isDragging {
                    commitValue(currentValue)
                }
            }
            .controlSize(.mini)
            .onAppear { currentValue = def }
        }
    }
}

struct Knob_Previews: PreviewProvider {
    static var previews: some View {
        Knob(name: "Test knob", def: 500, min: 10, max: 1000) { val in
            print("New value: \(val)")
        }
    }
}
