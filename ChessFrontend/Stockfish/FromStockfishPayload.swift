//
//  FromStockfishPayload.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 6/11/22.
//

import Foundation

enum FromStockfishPayload {
    enum IDParams {
        case author(String)
        case name(String)
    }
    enum Info {
        
    }

    case ready
    case uciOK
    case id(IDParams)
}
