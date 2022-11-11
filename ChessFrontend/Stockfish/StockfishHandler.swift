//
//  StockfishHandler.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 4/11/22.
//

import Foundation

/// Facilitates various interactions with the Stockfish chess engine
class StockfishHandler {
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
            let info = await waitForResponse()
            print("info")
            print(info)
            let res = await sendCommand("uci") { $0 == "uciok\n" }
            print("result:")
            print(res)
            let ready = await sendCommand("isready")
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
    ) async -> [StockfishResponse] {
        let handle = outPipe.fileHandleForReading
        return await withCheckedContinuation { continuation in
            handle.readabilityHandler = { handle in
                let str = String(decoding: handle.availableData, as: UTF8.self)
                var payloads: [StockfishResponse] = []
                for chunk in str.components(separatedBy: "\n") {
                    payloads.append(Self.parseResponse(chunk))
                    if terminatorPredicate(chunk + "\n") {
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
        chunk.isEmpty || chunk.last?.isNewline == true
    }

    /// Send a command to the engine through stdin and get its response
    ///
    /// - Parameters:
    ///   - command: The command to write
    ///   - resultTerminator: The character sequence that signifies the end of a response for a command
    fileprivate func sendCommand(
        _ command: String,
        terminatorPredicate: @escaping TerminatorPredicate = defaultTerminatorPredicate
    ) async -> [StockfishResponse] {
        let writeCommand = command.last?.isNewline == true ? command : command + "\n"
        await writeInput(writeCommand.data(using: .utf8)!)
        return await waitForResponse(terminatorPredicate: terminatorPredicate)
    }
}

typealias TerminatorPredicate = (String) -> Bool

// Command parser
extension StockfishHandler {
    static fileprivate func parseResponse(_ response: String) -> StockfishResponse {
        guard !response.isEmpty else { return .unknown(response) }
        let tokens = response.components(separatedBy: " ")
        switch (tokens.first!) {
        case "readyok":
            return .ready
        case "uciok":
            return .uciOK
        default:
            return .unknown(response)
        }
    }
}

// Public API
extension StockfishHandler {
    
}
