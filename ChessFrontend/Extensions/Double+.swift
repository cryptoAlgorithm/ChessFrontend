//
//  Double+.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 15/11/22.
//

import Foundation

extension Double {
    var descriptionWithSign: String {
        (self.sign == .plus ? "+" : "") + String(self)
    }
}
