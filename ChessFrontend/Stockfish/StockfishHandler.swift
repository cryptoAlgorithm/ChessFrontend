//
//  StockfishHandler.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 4/11/22.
//

import Foundation

/// Facilitates various interactions with the Stockfish chess engine
final class StockfishHandler: ObservableObject {
    fileprivate let proc = Process()
    fileprivate let inPipe = Pipe()
    fileprivate let outPipe = Pipe()

    private(set) var isInit = false

    public private(set) var engineAuthor: String?
    public private(set) var engineName: String?

    public private(set) var options: [UCIResponse.Option] = []

    fileprivate let responseWaitGroup = DispatchGroup()
    fileprivate let engineInputGroup = DispatchGroup()

    /// Initialise an instance of the Stockfish handler
    ///
    /// Will attempt to start and communicate with the stockfish binary in the app's resources
    init() throws {
        try initProc()
        try proc.run()

        Task {
            _ = try await waitForResponse()
            let info = try await sendCommandGettingResponse(.uci) { $0 == "uciok" }
            for inf in info {
                if case let .id(ID) = inf {
                    switch ID {
                    case .name(let name): engineName = name
                    case .author(let author): engineAuthor = author
                    }
                }
            }
            print("stockfish ready")
            isInit = true
            NotificationCenter.default.post(name: .stockfishReady, object: [])
        }
    }

    deinit {
        proc.terminate()
        proc.waitUntilExit()
    }

    fileprivate static func posixErr(_ error: Int32) -> Error {
        NSError(domain: NSPOSIXErrorDomain, code: Int(error), userInfo: nil)
    }

    /// Initialise the Stockfish process
    private func initProc() throws {
        // Set the executable URL, terminating if the stockfish binary couldn't be found
        proc.executableURL = Bundle.main.url(forResource: "stockfish", withExtension: "")!
        proc.standardInput = inPipe
        proc.standardOutput = outPipe

        // Configure the pipe to not send a SIGPIPE of the pipe was already closed
        let fcntlResult = fcntl(inPipe.fileHandleForWriting.fileDescriptor, F_SETNOSIGPIPE, 1)
        guard fcntlResult >= 0 else { throw Self.posixErr(errno) }

        proc.terminationHandler = { _ in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .stockfishProcTerminated, object: nil)
            }
        }
    }
}

extension StockfishHandler {
    fileprivate func waitForResponse(
        terminatorPredicate: @escaping TerminatorPredicate = defaultTerminatorPredicate
    ) async throws -> [UCIResponse] {
        let handle = outPipe.fileHandleForReading
        let payloads = UCIResponseAccumulator()
        return try await withCheckedThrowingContinuation { continuation in
            responseWaitGroup.wait()
            responseWaitGroup.enter()
            print("entering group")
            handle.readabilityHandler = { handle in
                /*if handle.availableData.isEmpty {
                    handle.readabilityHandler = nil
                    continuation.resume(returning: [])
                }*/
                let str = String(decoding: handle.availableData, as: UTF8.self)
                for chunk in str.components(separatedBy: "\n") {
                    do {
                        if let parsed = try Self.parseResponse(chunk) { // Only append if parsed response isn't nil
                            // Simply wrapping the actor call with a Task probably isn't the proper
                            // way to get thread-safe code, but it appears to work fine in this situation
                            Task { await payloads.add(response: parsed) }
                        }
                    } catch {
                        print("throwing error \(error)")
                        handle.readabilityHandler = nil
                        continuation.resume(throwing: error)
                        return
                    }
                    if terminatorPredicate(chunk) {
                        handle.readabilityHandler = nil
                        Task {
                            continuation.resume(returning: await payloads.responses)
                            self.responseWaitGroup.leave()
                        }
                        break
                    }
                }
            }
        }
    }

    private func writeInput(_ input: Data) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            engineInputGroup.wait()
            engineInputGroup.enter()
            let writeIO = DispatchIO(type: .stream, fileDescriptor: inPipe.fileHandleForWriting.fileDescriptor, queue: .main) { _ in
                
            }
            let inputDD = input.withUnsafeBytes { DispatchData(bytes: $0) }
            writeIO.write(offset: 0, data: inputDD, queue: .main) { isDone, _, error in
                if isDone || error != 0 {
                    if error != 0 {
                        continuation.resume(throwing: Self.posixErr(error))
                        return
                    }
                    self.engineInputGroup.leave()
                    continuation.resume()
                }
            }
        }
    }

    private static func defaultTerminatorPredicate(_ chunk: String) -> Bool {
        true // so true
    }
}

/// Determine when a communication from the engine has completed
///
/// - Parameter chunk: The chunk received from the engine
/// - Returns: `true` if the current communication is complete, `false` if more input from the engine should be gathered
typealias TerminatorPredicate = (_ chunk: String) -> Bool

// MARK: - Command parser wrapper
extension StockfishHandler {
    static fileprivate func parseResponse(_ response: String) throws -> UCIResponse? {
        guard !response.isEmpty else { return nil }
        let tokens = response.components(separatedBy: " ")
        switch (tokens.first!) {
        case "readyok":
            return .ready
        case "uciok":
            return .uciOK
        case "option":
            return .option(try UCIDecode.decode(UCIResponse.Option.self, payload: response))
        case "id":
            return .id(try UCIDecode.decode(UCIResponse.ID.self, payload: response))
        case "info":
            return .info(try UCIDecode.decode(UCIResponse.Info.self, payload: response))
        case "bestmove":
            return .bestMove(try UCIDecode.decode(UCIResponse.BestMove.self, payload: response))
        default:
            return .unknown(response)
        }
    }
}

// MARK: - Public API
extension StockfishHandler {
    /// Send a command to the engine through stdin and get its response
    ///
    /// - Parameters:
    ///   - commandName: The command's name (first token in UCI string)
    ///   - parameters: Command parameters as a dictionary
    ///   - resultTerminator: The character sequence that signifies the end of a response for a command
    public func sendCommandGettingResponse(
        _ commandName: UCICommand,
        parameters: [String : String]? = nil,
        terminatorPredicate: @escaping TerminatorPredicate = defaultTerminatorPredicate
    ) async throws -> [UCIResponse] {
        try await sendCommand(commandName, parameters: parameters)
        print("waiting for response")
        return try await waitForResponse(terminatorPredicate: terminatorPredicate)
    }

    /// Send a command to the engine
    ///
    /// This method will construct the UCI command that will be sent to the engine by concatinating
    /// all provided parameters to the command.
    ///
    /// - Parameters:
    ///   - commandName: The command's name (first token in UCI string, not the whole UCI command)
    ///   - parameters: Command parameters as a dictionary
    ///
    /// ## See Also
    /// - ``sendCommandGettingResponse(_:parameters:terminatorPredicate:)``
    public func sendCommand(
        _ commandName: UCICommand,
        parameters: [String : String]? = nil
    ) async throws {
        var cmd = commandName.rawValue
        // Add parameters if present
        if let parameters = parameters {
            cmd += " "
            for (key, param) in parameters {
                cmd += key + " " + param + " "
            }
        }
        print("Writing input \(cmd)")
        cmd += "\n"
        try await writeInput(cmd.data(using: .utf8)!)
    }

    // MARK: Command aliases
    /// Wait for the engine to be ready, commonly used after long-running commands
    public func waitReady() async throws {
        _ = try await sendCommandGettingResponse(.isReady) { $0 == "readyok" }
    }

    /// Start a new game
    ///
    /// This will send the `ucinewgame` command 
    public func newGame() async throws {
        try await sendCommand(.newGame)
    }

    /// Update the engine's internal board with a list of moves
    ///
    /// - Parameter moves: an array of moves by _both players_ since the beginning of the game in expanded algebraic notation
    public func updatePosition(moves: [Move]) async throws {
        try await sendCommand(
            .position,
            parameters: ["startpos moves": moves.map { $0.description }.joined(separator: " ")]
        )
    }

    /// Update the engine's internal board with a FEN string
    ///
    /// - Parameter fen: FEN string describing the current state of the board
    public func updatePosition(fen: String) async throws {
        try await sendCommand(
            .position,
            parameters: ["fen": fen]
        )
    }

    /// Search for a move at a certain depth
    ///
    /// Set the location before using this function with ``StockfishHandler/updatePosition(moves:)``
    public func search(depth: Int = 20) async throws -> [UCIResponse] {
        try await sendCommandGettingResponse(.go, parameters: ["depth": String(depth)]) { print($0);return $0.hasPrefix("bestmove") }
    }
}
