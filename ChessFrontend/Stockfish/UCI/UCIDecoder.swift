//
//  UCIDecoder.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 11/11/22.
//

import Foundation

enum UCIDecodingError: Error {
    case keyNotFound(String)
}

protocol UCIDecoder {
    func decodeString<Key: UCIKey>(_ key: Key) -> String
    func decodeString<Key: UCIKey>(_ key: Key) -> String?
}
