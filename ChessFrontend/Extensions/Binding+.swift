//
//  Binding+.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 15/11/22.
//

import SwiftUI

public extension Binding {
    /// Convert any `Int`-like binding type to any `Float`-like type
    static func convert<TInt, TFloat>(
        from intBinding: Binding<TInt>
    ) -> Binding<TFloat> where TInt: BinaryInteger, TFloat: BinaryFloatingPoint {
        Binding<TFloat> (
            get: { TFloat(intBinding.wrappedValue) },
            set: { intBinding.wrappedValue = TInt($0) }
        )
    }

    /// Convert any `Float`-like binding type to any `Int`-like type
    static func convert<TFloat, TInt>(
        from floatBinding: Binding<TFloat>
    ) -> Binding<TInt> where TFloat: BinaryFloatingPoint, TInt: BinaryInteger {
        Binding<TInt> (
            get: { TInt(floatBinding.wrappedValue) },
            set: { floatBinding.wrappedValue = TFloat($0) }
        )
    }

    /// Convert any `Int` binding type to a `Bool` type
    static func convert<TInt>(
        from intBinding: Binding<TInt>
    ) -> Binding<Bool> where TInt: BinaryInteger {
        Binding<Bool> (
            get: { intBinding.wrappedValue == 1 ? true : false },
            set: { intBinding.wrappedValue = $0 ? 1 : 0 }
        )
    }
}
