//
//  UCIDecode.swift
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
struct UCIDecode {
    /// Decode a payload string into a ``UCIDecodable`` storage object
    public static func decode<Payload: UCIDecodable>(
        _ decoding: Payload.Type,
        payload: String
    ) throws -> Payload where Payload.Key.RawValue == String {
        let decoded = Self.decodePayload(decoding: payload, keys: decoding.Key.allCases.map { $0.rawValue.description })
        return try decoding.init(_Decoder(decoded: decoded))
    }
}

fileprivate extension UCIDecode {
    static func decodePayload(decoding payload: String, keys: [String]) -> DecodedPayload {
        // A temp dict for values to be added during decoding
        var dict: DecodedPayload = Dictionary(uniqueKeysWithValues: keys.map { ($0, []) })
        // The individual tokens in the space-delimited payload string
        let tokens = payload.components(separatedBy: .whitespaces)

        // The key we are currently decoding
        var currentKey: String?

        for token in tokens {
            // First check if the current token is a key
            if dict[token] != nil {
                // This is a token, so we add an element to the respective key in the dict
                dict[token]?.append("")
                // Update the currently-decoding key
                currentKey = token
                continue // Don't append the key itself to the element name
            }
            if let key = currentKey {
                // We are in the midst of decoding a token, so append the token to the last item in the
                // respective array, adding spaces as neccessary.
                var tempStr = dict[key]!.last! // Force-unwraps are used here as state is broken if any are nil
                if !tempStr.isEmpty { tempStr += (" " + token) } // This isn't the first token to be added, so add a space first
                else { tempStr += token }
                dict[key]![dict[key]!.count - 1] = tempStr
            }
        }
        return dict
    }
}

fileprivate struct _Decoder: UCIDecoder {
    let decoded: DecodedPayload

    func decodeString(_ key: String) throws -> String {
        guard let val = try decodeStringOptional(key) else {
            throw UCIDecodingError.keyNotFound(requestedKey: key)
        }
        return val
    }

    func decodeInt(_ key: String) throws -> Int {
        guard let val = try decodeIntOptional(key) else {
            throw UCIDecodingError.keyNotFound(requestedKey: key)
        }
        return val
    }

    func decodeBool(_ key: String) throws -> Bool {
        let strVal = try decodeString(key)
        guard let val = Bool(strVal) else {
            throw UCIDecodingError.dataCorrupted(value: strVal, requestedType: "Bool")
        }
        return val
    }

    func decodeArray(_ key: String) throws -> [String] {
        guard let val = decoded[key] else {
            throw UCIDecodingError.keyNotFound(requestedKey: key)
        }
        guard !val.isEmpty else {
            throw UCIDecodingError.keyNotFound(requestedKey: key)
        }
        return val
    }

    func decodeStringOptional(_ key: String) throws -> String? {
        let val = decoded[key]
        guard val == nil || val!.count <= 1 else {
            throw UCIDecodingError.tooManyElements(key: key, actualCount: val!.count)
        }
        return val?.count == 0 ? nil : val?[0]
    }

    func decodeIntOptional(_ key: String) throws -> Int? {
        if let strVal = try decodeStringOptional(key) {
            guard let val = Int(strVal) else {
                throw UCIDecodingError.dataCorrupted(value: strVal, requestedType: "Int")
            }
            return val
        } else {
            return nil
        }
    }
}

fileprivate typealias DecodedPayload = [String : [String]]
