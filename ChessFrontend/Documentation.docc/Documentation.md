# ``ChessFrontend``

The frontend for a chess bot, receiving player moves from a controller
and playing moves made by an UCI engine.

## Overview

The chess board and its plotter is controlled by an ESP32 controller
running a custom build of Marlin, allowing it to scan the board to
determine the human player's moves as well as physically move the AI's
pieces. Players are allowed to make moves both through the physical chess
board and this frontend.

This frontend receives player moves from the controller and
interfaces with a chess engine through the UCI protocol, sending the AI's
moves to the controller which then physically moves the computer player's
pieces.

## Topics

### Engine

Provides a simple interface for several engine commands.

- ``StockfishHandler``
- ``TerminatorPredicate``

### UCI

Various structs and enums that store data to and from the engine.

- ``UCICommand``
- ``UCIResponse``

### UCI Decoding

Parses UCI strings from the engine into ``UCIDecodable`` storage objects.

- ``UCIDecode``
- ``UCIDecoder``
- ``UCIDecodable``
- ``UCIDecodingError``
- ``UCIKey``

### Chess

Represents various aspects of items making up the logic and items behind
the game.

- ``BoardState``
- ``Piece``
- ``PieceType``
- ``PieceSide``
- ``Move``
- ``PieceLocation``

### SwiftUI Views

Views that make up the GUI of this app.

- ``ChessView``
- ``PieceView``
- ``ContentView``
- ``ChessFrontendApp``
- ``Launcher``
- ``TestApp``
