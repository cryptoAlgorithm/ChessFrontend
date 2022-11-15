//
//  Comparable+.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 15/11/22.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
