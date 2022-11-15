//
//  Int+.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 15/11/22.
//

import Foundation

extension Int {
    var numberOfDigits: Self {
        var cnt = 0
        var tempNum = self

        if tempNum == 0 { return 1 }

        while tempNum > 0 {
            tempNum /= 10
            cnt += 1
        }
        return cnt
    }
}
