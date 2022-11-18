//
//  UCICommand.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 12/11/22.
//

import Foundation

/// UCI commands that can be sent to the engine
public enum UCICommand: String {
    /// Tell engine to use the UCI protocol in following communications
    ///
    /// This should always be the first command sent to the engine so it knows what to expect
    /// in future commands. Following this command, the engine will respond with a list of
    /// ``UCIResponse/Option``s, ending with ``UCIResponse/uciOK``. The GUI can
    /// then use these commands to configure the engine if required.
    case uci

    /// Start a new game
    case newGame = "ucinewgame"

    /// Check if the engine is ready
    ///
    /// Commonly used to wait for the engine to be ready again after long-running operations,
    /// engine responds with ``UCIResponse/ready`` when it's ready.
    case isReady = "isready"

    /// Change the internal parameters of the engine
    ///
    /// The available options are sent from the engine after the ``UCICommand/uci``  command.
    case setOption = "setoption"

    /// Play moves on the engine's internal internal board.
    ///
    /// Specify the `startpos` option if the list of moves provided was from the initial board state,
    /// or use `fen` to provide the latest board state only. It is strongly recommended to use either
    /// of these options, although they are optional.
    ///
    /// > If the `startpos` option with expanded algebraic notation moves are used, all moves
    /// > from the start of the game must be sent in this command, not just the latest move.
    case position

    /// Start searching for a move based on the current position set by the ``UCICommand/position`` command.
    case go

    /// Stop searching as soon as possible
    ///
    /// Stops a search started by ``UCICommand/go``.
    case stop

    /// Tell the engine that the player has played the expected move
    ///
    /// The engine should continue searching but switch from pondering to normal search.
    case ponderhit

    /// Tell the engine to quit as soon as possible
    ///
    /// No further output will be sent from the engine following this command.
    case quit
}
