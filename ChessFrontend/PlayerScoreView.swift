//
//  PlayerScoreView.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 15/11/22.
//

import SwiftUI

/// A custom progress bar-like view that displays the player's scores
struct PlayerScoreView: View {
    /// The advantage of the white player, in pawns
    let score: Double
    /// Number of moves the white player can be mated in
    let mateIn: Int?

    @State private var hovered = false

    /// Maximum advantage of a player in pawns, after which the value is simply truncated
    static private let maxPawns = 5.0

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer(minLength: 0)
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.white.opacity(0.8))
                    // Score overlay on top of white rectangle
                    Text(score.descriptionWithSign)
                        .font(.caption2)
                        .foregroundColor(.black)
                        .padding(.leading, 2)
                }
                .frame(width: geometry.size.width * (
                    mateIn?.signum() == 1
                    ? 0
                    : mateIn?.signum() == -1
                        ? 1
                        : ((score+Self.maxPawns) / (Self.maxPawns*2)).clamped(to: 0.05...0.95)
                ))
                .animation(.spring(), value: score)
                .animation(.spring(), value: mateIn)
                .popover(isPresented: $hovered, arrowEdge: .leading) {
                    Text(score.descriptionWithSign)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(8)
                        .fixedSize()
                        .interactiveDismissDisabled() // Prevent dismissing popover by clicking outside
                }
            }
            .onHover { hovered = $0 }
            .background(.gray.opacity(0.25))
            .overlay {
                if let mateIn = mateIn {
                    Text("M\(abs(mateIn))").foregroundColor(mateIn < 0 ? .black : .white).fontWeight(.bold)
                }
            }
        }
        .frame(height: 12)
    }
}

struct PlayerScoreView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerScoreView(score: 0, mateIn: -5)
            .frame(width: 600)
        PlayerScoreView(score: 5, mateIn: nil)
            .frame(width: 600)
        PlayerScoreView(score: -5, mateIn: nil)
            .frame(width: 600)
    }
}
