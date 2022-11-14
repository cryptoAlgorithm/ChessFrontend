//
//  UCIDecoder.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 11/11/22.
//

import Foundation

/// An error that might be thrown by ``UCIDecoder``s while decoding a UCI string
enum UCIDecodingError: Error, LocalizedError {
    /// If the requested key to decode wasn't found
    case keyNotFound(requestedKey: String)
    /// If the data present at the given key could not be parsed as the requested type
    case dataCorrupted(value: String, requestedType: String)
    /// If a single value was requested, but an array was found instead
    case tooManyElements(key: String, actualCount: Int)
    /// If decoding failed for some other reason
    ///
    /// - Parameter message: More details regarding the decoding failure.
    case genericError(message: String)

    public var errorDescription: String? {
        switch self {
        case .keyNotFound(requestedKey: let requestedKey):
            return "Requested key \"\(requestedKey)\" not found"
        case .dataCorrupted(value: let value, requestedType: let type):
            return "Failed to decode value \"\(value)\" into requested type \(type)"
        case .tooManyElements(key: let key, actualCount: let count):
            return "Expected one element at key \"\(key)\", found \(count) instead"
        case .genericError(message: let msg):
            return msg
        }
    }
}

/// A protocol for decoders which decode values from UCI strings by keys
protocol UCIDecoder {
    /// Decode a `String` at a certain key
    ///
    /// - Throws: ``UCIDecodingError/keyNotFound(requestedKey:)`` if no value was found at the given key,
    ///           ``UCIDecodingError/tooManyElements(key:actualCount:)`` if an array was found at the given key instead
    /// - Returns: The `String` value present at the given key
    func decodeString(_ key: String) throws -> String

    /// Decode an `Int` at a certain key
    ///
    /// - Throws: ``UCIDecodingError/keyNotFound(requestedKey:)`` if no value was found at the given key,
    ///           ``UCIDecodingError/tooManyElements(key:actualCount:)`` if an array was found at the given key instead,
    ///           ``UCIDecodingError/dataCorrupted(value:requestedType:)`` if the retrieved string value could not be parsed as an Int
    /// - Returns: A parsed `Int` of the value present at the given key
    func decodeInt(_ key: String) throws -> Int

    /// Decode a `Bool` at a certain key
    ///
    /// - Throws: ``UCIDecodingError/keyNotFound(requestedKey:)`` if no value was found at the given key,
    ///           ``UCIDecodingError/tooManyElements(key:actualCount:)`` if an array was found at the given key instead,
    ///           ``UCIDecodingError/dataCorrupted(value:requestedType:)`` if the retrieved string value could not be parsed as a Bool
    /// - Returns: A parsed `Bool` of the value present at the given key
    func decodeBool(_ key: String) throws -> Bool

    /// Decode an array of `String`s at a certain key
    ///
    /// - Throws: ``UCIDecodingError/keyNotFound(requestedKey:)`` if no value was found at the given key
    /// - Returns: An array of `String`s
    func decodeArray(_ key: String) throws -> [String]

    /// Decode an optional `String` at a certain key
    ///
    /// - Throws: ``UCIDecodingError/tooManyElements(key:actualCount:)`` if an array was found at the given key instead
    /// - Returns: `nil` if no value was found at the requested key, otherwise the `String` value present at the given key
    func decodeStringOptional(_ key: String) throws -> String?

    /// Decode an optional `Int` at a certain key
    ///
    /// - Throws: ``UCIDecodingError/tooManyElements(key:actualCount:)`` if an array was found at the given key instead,
    ///           ``UCIDecodingError/dataCorrupted(value:requestedType:)`` if the retrieved string value could not be parsed as an Int
    /// - Returns: `nil` if no value was found at the requested key, otherwise the `String` value present at the given key
    func decodeIntOptional(_ key: String) throws -> Int?
}
