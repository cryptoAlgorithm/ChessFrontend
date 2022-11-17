//
//  PlayerTurnPill.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 15/11/22.
//

import SwiftUI

struct PlayerTurnPill: View {
    let isBot: Bool

    var body: some View {
        HStack(spacing: 6) {
            if isBot {
                ProgressView().progressViewStyle(.circular).controlSize(.small)
                Text("Thinking...")
            } else {
                Text("Your turn")
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(Color.accentColor)
        .cornerRadius(6)
    }
}

struct PlayerTurnPill_Previews: PreviewProvider {
    static var previews: some View {
        PlayerTurnPill(isBot: false)
        PlayerTurnPill(isBot: true)
    }
}
