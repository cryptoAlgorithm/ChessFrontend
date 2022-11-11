//
//  StockfishResponse.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 6/11/22.
//

import Foundation

enum StockfishResponse {
    /// Payload that informs the GUI of the engine's name or author
    enum IDParams {
        /// A payload containing the name of the engine
        case author(String)
        /// A payload containing the engine's author
        case name(String)
    }

    /// An UCI option
    ///
    /// Various types of options are defined, each with differing parameters.
    ///
    /// > Tip: Details about each case's associated value(s) are included within their
    /// > documentation discussion. Click on a case to view more details.
    enum Option {
        /// Option that can be set either be true or false
        ///
        /// > Associated Values:
        /// > - `String`: Option name
        /// > - `Bool`: Default value
        case check(String, Bool)

        /// Option that can be set a range of integers in a defined range
        ///
        /// > Associated Values:
        /// > - `String`: Option name
        /// > - `Int`: Default value
        /// > - `Int`: Minimum value
        /// > - `Int`: Maximum value
        case spin(String, Int, Int, Int)

        /// Option that can be set to different predefined string values
        ///
        /// > Associated Values:
        /// > - `String`: Option name
        /// > - `String`: Default selected value
        /// > -`[String]`: Possible options
        case combo(String, [String])

        /// Option that can be used to send a command to the engine with a press of a button
        ///
        /// > Associated Values:
        /// > - `String`: Option name
        case button(String)

        /// Option that can be an arbitrary string value
        ///
        /// > Associated Values:
        /// > - `String`: Option name
        /// > - `String`: Default value
        case string(String, String)
    }

    /// An information payload
    struct Info {
        
    }

    /// A `readyok` response from the engine
    case ready

    /// An `uciok` response from the engine
    case uciOK

    /// Payload identifying the engine
    case id(IDParams)

    /// An infomation payload, sent while searching for a move
    case info(Info)

    /// A payload describing an option that can be used to configure various engine parameters
    case option(Option)

    /// If the response couldn't be parsed as any known response type
    ///
    /// Raw response is included in the associated value.
    case unknown(String)
}
