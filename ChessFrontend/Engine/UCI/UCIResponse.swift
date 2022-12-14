//
//  UCIResponse.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 6/11/22.
//

import Foundation

public enum UCIResponse {
    /// Payload that informs the GUI of the engine's name or author
    public enum ID: UCIDecodable {
        public typealias Key = Keys

        public enum Keys: String, CaseIterable {
            case author
            case name
        }

        /// A payload containing the name of the engine
        case author(String)
        /// A payload containing the engine's author
        case name(String)

        public init(_ decoder: UCIDecoder) throws {
            if let author = try decoder.decodeStringOptional(Keys.author.rawValue) {
                self = .author(author)
            } else if let name = try decoder.decodeStringOptional(Keys.name.rawValue) {
                self = .name(name)
            } else {
                throw UCIDecodingError.genericError(
                    message: "Expected either a name or author key to be present, but found neither"
                )
            }
        }
    }

    /// An UCI option
    ///
    /// Various types of options are defined, each with differing parameters.
    ///
    /// > Tip: Details about each case's associated value(s) are included within their
    /// > documentation discussion. Click on a case to view more details.
    public enum Option: UCIDecodable, Identifiable {
        public typealias Key = Keys

        public enum Keys: String, CaseIterable {
            case name
            case type
            case defaultValue = "default"
            case min
            case max
            case values = "var"
        }

        public enum OptType: String {
            case check
            case spin
            case combo
            case button
            case string
        }

        public init(_ decoder: UCIDecoder) throws {
            let name = try decoder.decodeString(Keys.name.rawValue)
            let type = try decoder.decodeString(Keys.type.rawValue)
            switch OptType(rawValue: type) {
            case .button:
                self = .button(name: name)
            case .spin:
                self = .spin(
                    name: name,
                    default: try decoder.decodeInt(Keys.defaultValue.rawValue),
                    min: try decoder.decodeInt(Keys.min.rawValue),
                    max: try decoder.decodeInt(Keys.max.rawValue)
                )
            case .check:
                self = .check(
                    name: name,
                    default: try decoder.decodeBool(Keys.defaultValue.rawValue)
                )
            case .string:
                self = .string(name: name, default: try decoder.decodeString(Keys.defaultValue.rawValue))
            case .combo:
                self = .combo(name: name, options: try decoder.decodeArray(Keys.values.rawValue))
            default:
                self = .unknown(name: name, type: type)
            }
        }

        /// The ID of this option, for Identifiable conformance
        ///
        /// An alias of ``UCIResponse/Option/name``
        public var id: String { name }

        // This is kinda silly
        /// The name of this option
        public var name: String {
            switch self {
            case .button(name: let name):
                return name
            case .check(name: let name, default: _):
                return name
            case .combo(name: let name, options: _):
                return name
            case .spin(name: let name, default: _, min: _, max: _):
                return name
            case .string(name: let name, default: _):
                return name
            case .unknown(name: let name, type: _):
                return name
            }
        }

        /// Option that can be set either be true or false
        ///
        /// > Associated Values:
        /// > - `String`: Option name
        /// > - `Bool`: Default value
        case check(name: String, default: Bool)

        /// Option that can be set a range of integers in a defined range
        ///
        /// > Associated Values:
        /// > - `String`: Option name
        /// > - `Int`: Default value
        /// > - `Int`: Minimum value
        /// > - `Int`: Maximum value
        case spin(name: String, default: Int, min: Int, max: Int)

        /// Option that can be set to different predefined string values
        ///
        /// > Associated Values:
        /// > - `String`: Option name
        /// > - `String`: Default selected value
        /// > -`[String]`: Possible options
        case combo(name: String, options: [String])

        /// Option that can be used to send a command to the engine with a press of a button
        ///
        /// > Associated Values:
        /// > - `String`: Option name
        case button(name: String)

        /// Option that can be an arbitrary string value
        ///
        /// > Associated Values:
        /// > - `String`: Option name
        /// > - `String`: Default value
        case string(name: String, default: String)

        /// An unknown type
        case unknown(name: String, type: String)
    }

    /// An information payload
    public struct Info: UCIDecodable {
        public typealias Key = Keys

        public enum Keys: String, CaseIterable {
            case depth
            case selectiveDepth = "seldepth"
            case time
            case nodes
            case pv // Best play found
            case multiPV = "multipv"
            case centiPawns = "cp"
            case mateMoves = "mate"
            case lowerbound
            case upperbound
            case currentMove = "currmove"
            case currentMoveNumber = "currmovenumber"
            case hashFull = "hashfull"
            case nps
            case tableHits = "tbhits"
            case CPULoad = "cpuload"
            case displayString = "string"
            case refutation
            case currentLine = "currline"
        }

        public let depth: Int?
        public let currentMove: Move?
        public let currentMoveNumber: Int?
        public let centiPawnsScore: Int?
        public let mateMoves: Int?

        public init(_ decoder: UCIDecoder) throws {
            depth = try decoder.decodeIntOptional(Keys.depth.rawValue)
            if let currMove = try decoder.decodeStringOptional(Keys.currentMove.rawValue) {
                currentMove = try Move(from: currMove)
            } else { currentMove = nil }
            currentMoveNumber = try decoder.decodeIntOptional(Keys.currentMoveNumber.rawValue)
            centiPawnsScore = try decoder.decodeIntOptional(Keys.centiPawns.rawValue)
            mateMoves = try decoder.decodeIntOptional(Keys.mateMoves.rawValue)
        }
    }

    /// A best move
    public struct BestMove: UCIDecodable {
        public typealias Key = Keys

        public enum Keys: String, CaseIterable {
            case bestmove
            case ponder
        }

        public let move: Move
        public let ponder: Move?

        public init(_ decoder: UCIDecoder) throws {
            move = try Move(from: try decoder.decodeString(Keys.bestmove.rawValue))
            if let ponderLoc = try decoder.decodeStringOptional(Keys.ponder.rawValue) {
                ponder = try Move(from: ponderLoc)
            } else { ponder = nil }
        }
    }

    /// A `readyok` response from the engine
    case ready

    /// An `uciok` response from the engine
    case uciOK

    /// Payload identifying the engine
    case id(ID)

    /// An infomation payload, sent while searching for a move
    case info(Info)

    /// A payload describing an option that can be used to configure various engine parameters
    case option(Option)

    /// The best move as determined by the engine
    case bestMove(BestMove)

    /// If the response couldn't be parsed as any known response type
    ///
    /// Raw response is included in the associated value.
    case unknown(String)
}

/// Allows mutating an array of ``UCIResponse``s in a thread-safe fashon
actor UCIResponseAccumulator {
    /// An array of accumulated ``UCIResponse``s
    var responses: [UCIResponse] = []

    /// Add a response to the array of responses
    func add(response: UCIResponse) {
        responses.append(response)
    }
}
