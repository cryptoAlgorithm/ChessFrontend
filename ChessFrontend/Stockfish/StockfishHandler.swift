//
//  StockfishHandler.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 4/11/22.
//

import Foundation

/// Facilitates various interactions with the Stockfish chess engine
final class StockfishHandler {
    fileprivate let proc = Process()
    fileprivate let inPipe = Pipe()
    fileprivate let outPipe = Pipe()

    private(set) var isInit = false

    /// Initialise an instance of the Stockfish handler
    ///
    /// Will attempt to start and communicate with the stockfish binary in the app's resources
    init() throws {
        try initProc()
        try proc.run()
        print(proc.processIdentifier)

        Task {
            let info = try await waitForResponse()
            print("info")
            print(info)
            let res = try await sendCommand("uci") { $0 == "uciok" }
            print("result:")
            print(res)
            let ready = try await sendCommand("isready")
            print(ready)
            
        }
    }

    deinit {
        proc.terminate()
        proc.waitUntilExit()
    }

    fileprivate func posixErr(_ error: Int32) -> Error { NSError(domain: NSPOSIXErrorDomain, code: Int(error), userInfo: nil) }

    /// Initialise the Stockfish process
    private func initProc() throws {
        // Set the executable URL, terminating if the stockfish binary couldn't be found
        proc.executableURL = Bundle.main.url(forResource: "stockfish", withExtension: "")!
        proc.standardInput = inPipe
        proc.standardOutput = outPipe

        // Configure the pipe to not send a SIGPIPE of the pipe was already closed
        let fcntlResult = fcntl(inPipe.fileHandleForWriting.fileDescriptor, F_SETNOSIGPIPE, 1)
        guard fcntlResult >= 0 else { throw posixErr(errno) }

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
    ) async throws -> [StockfishResponse] {
        let handle = outPipe.fileHandleForReading
        return try await withCheckedThrowingContinuation { continuation in
            handle.readabilityHandler = { handle in
                let str = String(decoding: handle.availableData, as: UTF8.self)
                var payloads: [StockfishResponse] = []
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

    private func writeInput(_ input: Data) async {
        return await withCheckedContinuation { continuation in
            let writeIO = DispatchIO(type: .stream, fileDescriptor: inPipe.fileHandleForWriting.fileDescriptor, queue: .main) { _ in
                
            }
            let inputDD = input.withUnsafeBytes { DispatchData(bytes: $0) }
            writeIO.write(offset: 0, data: inputDD, queue: .main) { isDone, _, error in
                if isDone || error != 0 {
                    if error != 0 { print("haiya error") }
                    continuation.resume()
                }
            }
        }
    }

    private static func defaultTerminatorPredicate(_ chunk: String) -> Bool {
        true
    }
}

typealias TerminatorPredicate = (String) -> Bool

// Command parser
extension StockfishHandler {
    static fileprivate func parseResponse(_ response: String) throws -> StockfishResponse? {
        guard !response.isEmpty else { return nil }
        let tokens = response.components(separatedBy: " ")
        switch (tokens.first!) {
        case "readyok":
            return .ready
        case "uciok":
            return .uciOK
        case "option":
            return .option(try UCISpecificDecoder().decode(StockfishResponse.Option.self, payload: response))
        case "id":
            return .id(try UCISpecificDecoder().decode(StockfishResponse.ID.self, payload: response))
        default:
            return .unknown(response)
        }
    }
}

// Public API
extension StockfishHandler {
    /// Send a command to the engine through stdin and get its response
    ///
    /// - Parameters:
    ///   - command: The command to write
    ///   - resultTerminator: The character sequence that signifies the end of a response for a command
    public func sendCommand(
        _ command: String,
        parameters: [String : String]? = nil,
        terminatorPredicate: @escaping TerminatorPredicate = defaultTerminatorPredicate
    ) async throws -> [StockfishResponse] {
        var cmd = command.last?.isNewline == true ? command : command + "\n"
        // Add parameters if present
        if let parameters = parameters {
            cmd += " "
            for (key, param) in parameters {
                cmd += key + " " + param + " "
            }
        }
        await writeInput(cmd.data(using: .utf8)!)
        return try await waitForResponse(terminatorPredicate: terminatorPredicate)
    }

    // Command aliases
    
    /// Wait for the engine to be ready, commonly used after long-running commands
    public func waitReady() async {
        
    }
}
