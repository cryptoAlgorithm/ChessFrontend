//
//  Check.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 15/11/22.
//

import SwiftUI

struct Check: View {
    let name: String
    let def: Bool
    let commitValue: (Bool) async throws -> Void

    // Set an initial value to something unique so we know we're setting the default in .onChange
    @State private var checked = -1
    @State private var committing = false

    var body: some View {
        HStack(spacing: 6) {
            Toggle(isOn: .convert(from: $checked)) {
                Text(name).font(.callout).frame(maxWidth: .infinity, alignment: .leading)
            }
            .onChange(of: checked) { [checked] val in
                if checked != -1 {
                    Task {
                        committing = true
                        try await commitValue(val == 1 ? true : false)
                        committing = false
                    }
                }
            }
            .onAppear {
                checked = def ? 1 : 0
            }
            .disabled(committing)
            .toggleStyle(.switch)
            .controlSize(.mini)
        }
    }
}

struct Check_Previews: PreviewProvider {
    static var previews: some View {
        Check(name: "Test check option", def: false) { _ in }
    }
}
