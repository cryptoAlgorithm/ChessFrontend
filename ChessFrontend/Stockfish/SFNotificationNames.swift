//
//  SFNotificationNames.swift
//  ChessFrontend
//
//  This file doesn't follow the naming convention for 2 reasons:
//    1. I forsee adding many more notification names for differen subsystems
//       in the future, which would get messy if they were all added in a single file.
//       Files added to a target must have unique names, which meant that
//       this extension must have a more specific name.
//    2. Following naming convention, this file would be named "NSNotification.Name+.swift",
//       which is slightly too long for my liking.
//
//  Created by Vincent Kwok on 5/11/22.
//

import Foundation

extension NSNotification.Name {
    static let stockfishProcTerminated = Self("stockfish-proc-term")
    static let stockfishReady = Self("stockfish-ready")
    static let stockfishCPUpdate = Self("stockfish-cp")
    static let stockfishOptionsUpdate = Self("stockfish-opts")
}
