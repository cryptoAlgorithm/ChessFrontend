//
//  UCIDecoder.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 11/11/22.
//

import Foundation

enum UCIDecodingError: Error, LocalizedError {
    case keyNotFound(requestedKey: String)
    case dataCorrupted(value: String, requestedType: String)
    case tooManyElements(key: String, actualCount: Int)
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

protocol UCIDecoder {
    func decodeString(_ key: String) throws -> String

    func decodeInt(_ key: String) throws -> Int

    func decodeBool(_ key: String) throws -> Bool

    func decodeArray(_ key: String) throws -> [String]

    func decodeStringOptional(_ key: String) throws -> String?
}
