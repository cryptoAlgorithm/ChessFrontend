//
//  UCISpecificDecoder.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 10/11/22.
//

import Foundation

/// A utility decoder for decoding UCI payload strings into structs
///
/// This does not conform to Swift's Decoder for good reason as the Decoder protocol is
/// overkill and is not fitting to be used here. It requires the keys of the data to be known
/// before decoding, but that is not possible with the UCI protocol.
struct UCISpecificDecoder {
    public func decode<Payload: UCIDecodable>(_ decoding: Payload.Type, payload: String) throws -> Payload {
        decoding.Key.allCases.map { $0.rawValue }
        return try decoding.init(_Decoder(decoded: [:]))
    }
}

fileprivate extension UCISpecificDecoder {
    
}

fileprivate struct _Decoder: UCIDecoder {
    let decoded: [String : String]

    func decodeString<Key: UCIKey>(_ key: Key) -> String {
        ""
    }

    func decodeString<Key: UCIKey>(_ key: Key) -> String? {
        nil
    }
}
