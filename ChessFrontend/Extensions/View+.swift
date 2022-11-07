//
//  View+.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 4/11/22.
//

import SwiftUI

// Adapted from a random StackOverflow answer
struct Draggable<Preview>: ViewModifier where Preview: View {
    let condition: Bool
    let data: () -> NSItemProvider
    @ViewBuilder let preview: () -> Preview

    @ViewBuilder
    func body(content: Content) -> some View {
        if condition {
            content.onDrag(data, preview: preview)
        } else {
            content
        }
    }
}

extension View {
    public func onDrag<Preview>(
        if condition: Bool,
        data: @escaping () -> NSItemProvider,
        @ViewBuilder preview: @escaping () -> Preview
    ) -> some View where Preview: View {
        self.modifier(Draggable(condition: condition, data: data, preview: preview))
    }
}
