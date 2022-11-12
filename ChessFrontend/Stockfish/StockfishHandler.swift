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
                    if case let .name(name) = ID {
                        engineName = name
                    } else if case let .author(author) = ID {
                        engineAuthor = author
                    }
                }
            }
            try await waitReady()
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
        return try await withCheckedThrowingContinuation { continuation in
            handle.readabilityHandler = { handle in
                let str = String(decoding: handle.availableData, as: UTF8.self)
                var payloads: [UCIResponse] = []
                for chunk in str.components(separatedBy: "\n") {
                    do {
                        if let parsed = try Self.parseResponse(chunk) { // Only append if parsed response isn't nil
                            payloads.append(parsed)
                        }
                    } catch {
                        continuation.resume(throwing: error)
                        return
                    }
                    if terminatorPredicate(chunk) {
                        handle.readabilityHandler = nil
                        continuation.resume(returning: payloads)
                        return
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

    private static func defaultTerminatorPredicate(_ chunk: String) -> Bool {
        true // so true
    }
}

typealias TerminatorPredicate = (String) -> Bool

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
        var cmd = commandName.rawValue + "\n"
        // Add parameters if present
        if let parameters = parameters {
            cmd += " "
            for (key, param) in parameters {
                cmd += key + " " + param + " "
            }
        }
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
}
