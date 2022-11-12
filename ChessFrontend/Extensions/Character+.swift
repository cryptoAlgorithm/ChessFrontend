//
//  Character+.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 12/11/22.
//

import Foundation

extension Character {
    /// Create a character instance from an unicode char code
    init(charCode: Int) {
        self.init(UnicodeScalar(charCode)!)
    }
}
