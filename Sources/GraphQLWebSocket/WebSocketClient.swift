//
//  WebSocketClient.swift
//
//
//  Created by Michał A on 2023/10/25.
//

// MARK: - Starscream types

// see also https://github.com/daltoniam/Starscream/blob/master/Sources/Starscream/WebSocket.swift

import Foundation

public protocol WebSocketClient: AnyObject {
    func connect()
    func disconnect(closeCode: UInt16)
    func write(string: String, completion: (() -> ())?)
    func write(stringData: Data, completion: (() -> ())?)
    func write(data: Data, completion: (() -> ())?)
    func write(ping: Data, completion: (() -> ())?)
    func write(pong: Data, completion: (() -> ())?)
}

extension WebSocketClient {
    func write(string: String) {
        write(string: string, completion: nil)
    }
    
    func write(data: Data) {
        write(data: data, completion: nil)
    }
    
    func write(ping: Data) {
        write(ping: ping, completion: nil)
    }
    
    func write(pong: Data) {
        write(pong: pong, completion: nil)
    }
    
    func disconnect() {
        disconnect(closeCode: UInt16(URLSessionWebSocketTask.CloseCode.normalClosure.rawValue))
    }
    
    func write(stringData: Data, completion: (() -> ())?) {
        let string = String(data: stringData, encoding: .utf8)!
        write(string: string, completion: completion)
    }
    
    func write(stringData: Data) {
        write(stringData: stringData, completion: nil)
    }
}

public enum WebSocketEvent {
    case connected([String: String])
    case disconnected(String, UInt16)
    case text(String)
    case binary(Data)
    case pong(Data?)
    case ping(Data?) // NOTE: not used
    case error(Error?)
    case viabilityChanged(Bool) // NOTE: not used
    case reconnectSuggested(Bool) // NOTE: not used
    case cancelled // NOTE: not used
    case peerClosed // NOTE: not used
}

protocol WebSocketDelegate: AnyObject {
    func didReceive(event: WebSocketEvent, client: WebSocketClient)
}

private enum HTTPWSHeader {
    static let protocolName = "Sec-WebSocket-Protocol"
}

// MARK: - URLSession replacement of Starscream WebSocket

// see also https://github.com/daltoniam/Starscream/blob/master/Sources/Engine/NativeEngine.swift

class WebSocket: NSObject, WebSocketClient, URLSessionWebSocketDelegate {
    weak var delegate: WebSocketDelegate?
    
    private let callbackQueue: DispatchQueue
    
    private let socket: URLSessionWebSocketTask
    
    init(request: URLRequest, session: URLSession = .shared, callbackQueue: DispatchQueue = DispatchQueue.main) {
        assert(request.allHTTPHeaderFields?[HTTPWSHeader.protocolName] != nil)
        socket = session.webSocketTask(with: request)
        self.callbackQueue = callbackQueue
    }

    /// Starts receiving incoming messages.
    private func receive() {
        socket.receive { [weak self] result in
            guard let self else { return }
            self.callbackQueue.async {
                switch result {
                case let .success(message):
                    switch message {
                    case let .data(data):
                        self.delegate?.didReceive(event: .binary(data), client: self)
                    case let .string(string):
                        self.delegate?.didReceive(event: .text(string), client: self)
                    @unknown default:
                        assertionFailure("Unknown message type")
                    }
                case let .failure(error):
                    self.delegate?.didReceive(event: .error(error), client: self)
                }
            }
            self.receive()
        }
    }
    
    // MARK: WebSocketClient
    
    func connect() {
        assert(socket.state == .suspended)
        socket.delegate = self
        receive()
        socket.resume()
    }
    
    func disconnect(closeCode: UInt16) {
        assert(socket.state == .running)
        // NOTE: URLSessionWebSocketTask.CloseCode limits allowed close codes
        let closeCode = URLSessionWebSocketTask.CloseCode(rawValue: Int(closeCode)) ?? .normalClosure
        socket.cancel(with: closeCode, reason: nil)
    }
    
    func write(string: String, completion: (() -> ())?) {
        assert(socket.state == .running)
        socket.send(.string(string)) { error in
            // NOTE: Starscream NativeEngine ignores the error
            assert(error == nil)
            completion?()
        }
    }

    func write(data: Data, completion: (() -> ())?) {
        assert(socket.state == .running)
        socket.send(.data(data)) { error in
            // NOTE: Starscream NativeEngine ignores the error
            assert(error == nil)
            completion?()
        }
    }
    
    func write(ping: Data, completion: (() -> ())?) {
        assert(socket.state == .running)
        socket.sendPing(pongReceiveHandler: { error in
            // NOTE: Starscream NativeEngine ignores the error
            assert(error == nil)
            completion?()
            guard error == nil else { return }
            self.callbackQueue.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceive(event: .pong(nil), client: self)
            }
        })
    }
    
    func write(pong: Data, completion: (() -> ())?) {
        // NOTE: URLSessionWebSocketTask reponds to PINGs sent by server
        completion?()
    }
    
    // MARK: URLSessionWebSocketDelegate
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        callbackQueue.async { [weak self] in
            guard let self else { return }
            let protocolName = `protocol` ?? ""
            self.delegate?.didReceive(event: .connected([HTTPWSHeader.protocolName: protocolName]), client: self)
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        callbackQueue.async { [weak self] in
            guard let self else { return }
            let message = reason.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            let closeCode = UInt16(closeCode.rawValue)
            self.delegate?.didReceive(event: .disconnected(message, closeCode), client: self)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        callbackQueue.async { [weak self] in
            guard let self else { return }
            self.delegate?.didReceive(event: .error(error), client: self)
        }
    }
}
