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
    func disconnect(closeCode: Int)
    func send(_ string: String, completion: ((Error?) -> ())?)
    func send(_ data: Data, completion: ((Error?) -> ())?)
    /// Note that the callback is called after PING is sent and PONG received.
    func sendPing(pongReceiveHandler: ((Error?) -> ())?)
}

extension WebSocketClient {
    func disconnect() {
        disconnect(closeCode: URLSessionWebSocketTask.CloseCode.normalClosure.rawValue)
    }
}

public enum WebSocketEvent {
    case connected(protocolName: String?)
    case disconnected(message: String?, closeCode: Int)
    case text(String)
    case binary(Data)
    case pong
    case error(Error?)
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
        assert(delegate != nil, "Delegate not set")
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

    func disconnect(closeCode: Int) {
        // NOTE: URLSessionWebSocketTask.CloseCode limits allowed close codes
        let closeCode = URLSessionWebSocketTask.CloseCode(rawValue: Int(closeCode)) ?? .normalClosure
        socket.cancel(with: closeCode, reason: nil)
    }

    func send(_ string: String, completion: ((Error?) -> ())?) {
        assert(socket.state == .running)
        socket.send(.string(string)) { error in
            completion?(error)
        }
    }

    func send(_ data: Data, completion: ((Error?) -> ())?) {
        assert(socket.state == .running)
        socket.send(.data(data)) { error in
            completion?(error)
        }
    }

    func sendPing(pongReceiveHandler completion: ((Error?) -> ())?) {
        assert(socket.state == .running)
        socket.sendPing(pongReceiveHandler: { error in
            completion?(error)
            guard error == nil else { return }
            self.callbackQueue.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceive(event: .pong, client: self)
            }
        })
    }

    // MARK: URLSessionWebSocketDelegate

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        callbackQueue.async { [weak self] in
            guard let self else { return }
            let protocolName = `protocol` ?? ""
            self.delegate?.didReceive(event: .connected(protocolName: protocolName), client: self)
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        callbackQueue.async { [weak self] in
            guard let self else { return }
            let message = reason.flatMap { String(data: $0, encoding: .utf8) }
            let closeCode = closeCode.rawValue
            self.delegate?.didReceive(event: .disconnected(message: message, closeCode: closeCode), client: self)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        callbackQueue.async { [weak self] in
            guard let self else { return }
            self.delegate?.didReceive(event: .error(error), client: self)
        }
    }
}
