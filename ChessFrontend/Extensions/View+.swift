//
//  View+.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 4/11/22.
//

import SwiftUI

// Adapted from a random StackOverflow answer
struct Draggable: ViewModifier {
    let condition: Bool
    let data: () -> NSItemProvider

    @ViewBuilder
    func body(content: Content) -> some View {
        if condition {
            content.onDrag(data)
        } else {
            content
        }
    }
}

extension View {
    public func onDrag(
        if condition: Bool,
        data: @escaping () -> NSItemProvider
    ) -> some View {
        self.modifier(Draggable(condition: condition, data: data))
    }
}
