//
//  AnyTransition+.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 15/11/22.
//

import SwiftUI

extension AnyTransition {
    static public var asymmetricTrailingPush: AnyTransition {
        if #available(macOS 13.0, *) {
            return .asymmetric(insertion: .push(from: .trailing), removal: .push(from: .leading))
        } else {
            return .move(edge: .trailing).combined(with: .opacity)
        }
    }

    static public var asymmetricLeadingPush: AnyTransition {
        if #available(macOS 13.0, *) {
            return .asymmetric(insertion: .push(from: .leading), removal: .push(from: .trailing))
        } else {
            return .move(edge: .leading).combined(with: .opacity)
        }
    }
}
