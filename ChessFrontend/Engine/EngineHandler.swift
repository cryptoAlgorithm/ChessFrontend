//
//  EngineHandler.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 4/11/22.
//

import Foundation

/// Facilitates various interactions with the Stockfish chess engine
public final class EngineHandler: ObservableObject {
    fileprivate let proc = Process()
    fileprivate let inPipe = Pipe()
    fileprivate let outPipe = Pipe()

    private(set) var isInit = false

    public private(set) var engineAuthor: String?
    public private(set) var engineName: String?

    public private(set) var options: [UCIResponse.Option] = []

    fileprivate let engineIOGroup = DispatchGroup()

    /// Initialise an instance of this class to interface with an UCI chess engine
    ///
    /// Will attempt to start and communicate with the supplied binary thru the UCI
    /// protocol.
    ///
    /// - Parameter binaryURL: URL to engine binary
    /// - Throws: If a process or decoding error occurred during initialisation
    public init(with binaryURL: URL, completionHandler: @escaping () -> () = {}) throws {
        try initProc(with: binaryURL)
        try proc.run()

        Task {
            _ = try await waitForResponse()

            // Get and decode options
            let info = try await sendCommandGettingResponse(.uci) { $0 == "uciok" }
            for inf in info {
                if case let .id(ID) = inf {
                    switch ID {
                    case .name(let name): engineName = name
                    case .author(let author): engineAuthor = author
                    }
                } else if case let .option(option) = inf {
                    options.append(option)
                }
            }

            try await setOptionValue("Threads", value: String(ProcessInfo().activeProcessorCount))
            isInit = true

            DispatchQueue.main.async { [weak self] in
                NotificationCenter.default.post(name: .engineOptionsUpdate, object: self?.options)
                NotificationCenter.default.post(name: .engineReady, object: nil)

                completionHandler()
            }
        }
    }

    deinit {
        proc.terminate()
        proc.waitUntilExit()
    }

    fileprivate static func posixErr(_ error: Int32) -> Error {
        NSError(domain: NSPOSIXErrorDomain, code: Int(error), userInfo: nil)
    }

    /// Initialise the engine process
    ///
    /// - Parameter executable: URL to engine binary
    private func initProc(with executable: URL) throws {
        // Set the executable URL, terminating if the stockfish binary couldn't be found
        proc.executableURL = executable
        proc.standardInput = inPipe
        proc.standardOutput = outPipe

        // Configure the pipe to not send a SIGPIPE of the pipe was already closed
        let fcntlResult = fcntl(inPipe.fileHandleForWriting.fileDescriptor, F_SETNOSIGPIPE, 1)
        guard fcntlResult >= 0 else { throw Self.posixErr(errno) }

        proc.terminationHandler = { _ in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .engineProcTerminated, object: nil)
            }
        }
    }
}

extension EngineHandler {
    fileprivate func waitForResponse(
        terminatorPredicate: TerminatorPredicate? = nil,
        useGroup: Bool = true
    ) async throws -> [UCIResponse] {
        let handle = outPipe.fileHandleForReading
        let payloads = UCIResponseAccumulator()
        if useGroup {
            engineIOGroup.wait()
            engineIOGroup.enter()
        }

        return try await withCheckedThrowingContinuation { continuation in
            handle.readabilityHandler = { handle in
                // Must assign to a var because reading this property removes the read data from the buffer,
                // so subsequent calls don't get any more data
                let data = handle.availableData
                if data.isEmpty {
                    handle.readabilityHandler = nil
                    continuation.resume(returning: [])
                    if useGroup { self.engineIOGroup.leave() }
                    return
                }
                let str = String(decoding: data, as: UTF8.self)
                // Simply wrapping the actor calls with a Task probably isn't the proper
                // way to get thread-safe code, but it appears to work fine in this situation
                Task {
                    for chunk in str.components(separatedBy: "\n") {
                        do {
                            if let parsed = try Self.parseResponse(chunk) { // Only append if parsed response isn't nil
                                await payloads.add(response: parsed)
                            }
                        } catch {
                            print("throwing error \(error)")
                            handle.readabilityHandler = nil
                            continuation.resume(throwing: error)
                            if useGroup { self.engineIOGroup.leave() }
                            return
                        }
                        if terminatorPredicate?(chunk) ?? true {
                            handle.readabilityHandler = nil
                            continuation.resume(returning: await payloads.responses)
                            if useGroup { self.engineIOGroup.leave() }
                            return
                        }
                    }
                }
            }
        }
    }

    private func writeInput(_ input: Data) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let writeIO = DispatchIO(type: .stream, fileDescriptor: inPipe.fileHandleForWriting.fileDescriptor, queue: .main) { _ in
                
            }
            let inputDD = input.withUnsafeBytes { DispatchData(bytes: $0) }
            writeIO.write(offset: 0, data: inputDD, queue: .main) { isDone, _, error in
                if isDone || error != 0 {
                    if error != 0 {
                        continuation.resume(throwing: Self.posixErr(error))
                        return
                    }
                    continuation.resume()
                }
            }
        }
    }

    static func defaultTerminatorPredicate(_ chunk: String) -> Bool {
        true // so true
    }
}

/// Determine when a communication from the engine has completed
///
/// - Parameter chunk: The chunk received from the engine
/// - Returns: `true` if the current communication is complete, `false` if more input from the engine should be gathered
public typealias TerminatorPredicate = (_ chunk: String) -> Bool

// MARK: - Command parser wrapper
extension EngineHandler {
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
extension EngineHandler {
    /// Send a command to the engine through stdin and get its response
    ///
    /// - Parameters:
    ///   - commandName: The command's name (first token in UCI string)
    ///   - parameters: Command parameters as a dictionary
    ///   - resultTerminator: The character sequence that signifies the end of a response for a command
    public func sendCommandGettingResponse(
        _ commandName: UCICommand,
        parameters: [String : String]? = nil,
        terminatorPredicate: TerminatorPredicate? = nil
    ) async throws -> [UCIResponse] {
        defer { engineIOGroup.leave() } // Leave group once we're done
        try await sendCommand(commandName, parameters: parameters, leaveGroup: false)
        let resp = try await waitForResponse(terminatorPredicate: terminatorPredicate, useGroup: false)
        return resp
    }

    /// Send a command to the engine
    ///
    /// This method will construct the UCI command that will be sent to the engine by concatinating
    /// all provided parameters to the command.
    ///
    /// - Parameters:
    ///   - commandName: The command's name (first token in UCI string, not the whole UCI command)
    ///   - parameters: Command parameters as a dictionary
    ///   - leaveGroup: If the `engineIOGroup` should be left after this method completes
    ///
    /// ## See Also
    /// - ``sendCommandGettingResponse(_:parameters:terminatorPredicate:)``
    public func sendCommand(
        _ commandName: UCICommand,
        parameters: [String : String]? = nil,
        leaveGroup: Bool = true
    ) async throws {
        engineIOGroup.wait()
        engineIOGroup.enter()
        defer { if leaveGroup { engineIOGroup.leave() }}

        var cmd = commandName.rawValue
        // Add parameters if present
        if let parameters = parameters {
            cmd += " "
            for (key, param) in parameters {
                cmd += key + " " + param + " "
            }
        }
        cmd = cmd.trimmingCharacters(in: .whitespacesAndNewlines) // Get rid of any erroneous characters surrounding the command
        print("Writing input '\(cmd)'")
        cmd += "\n"
        try await writeInput(cmd.data(using: .utf8)!)
    }

    // MARK: Command aliases
    /// Wait for the engine to be ready, commonly used after long-running commands
    ///
    /// This _should_ be called by implementations after ``newGame()`` and `uci` commands,
    /// which do not explicitly output anything after they have successfully completed.
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
    /// or ``StockfishHandler/updatePosition(fen:)``
    public func search(depth: Int = 20) async throws -> [UCIResponse] {
        try await sendCommandGettingResponse(.go, parameters: ["depth": String(depth)]) { respChunk in
            // print(respChunk)
            if let parsed = try? Self.parseResponse(respChunk),
               case .info(let info) = parsed, let cp = info.centiPawnsScore {
                DispatchQueue.main.async { // Post a notification to update the UI
                    NotificationCenter.default.post(name: .engineCPUpdate, object: (cp, info.mateMoves))
                }
            }
            return respChunk.hasPrefix("bestmove")
        }
    }

    /// Update the value of an option in the engine
    ///
    /// This method expects a valid name and value for the option and does _no_ validation.
    public func setOptionValue(_ name: String, value: String) async throws {
        try await sendCommand(.setOption, parameters: [
            "name": name,
            "value": value
        ])
    }
}
