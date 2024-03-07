import Foundation
import WebSocketKit
import NIOTransportServices
import NIOConcurrencyHelpers
import NIOWebSocket
import NIOCore
import NIO

public protocol WebSocketDelegate: AnyObject {
    func didReceive(event: WebSocketEvent, client: WebSocketClient)
}

public protocol WebSocketClient: AnyObject {
    func connect()
    func disconnect(closeCode: UInt16)
    func write(string: String, completion: (() -> ())?)
    func write(stringData: Data, completion: (() -> ())?)
    func write(data: Data, completion: (() -> ())?)
    func write(ping: Data, completion: (() -> ())?)
    func write(pong: Data, completion: (() -> ())?)
}

public enum WebSocketEvent {
    case connected([String: String])
    case disconnected(String, UInt16)
    case text(String)
    case binary(Data)
    case pong(Data?)
    case ping(Data?)
    case error(Error?)
    case viabilityChanged(Bool)
    case reconnectSuggested(Bool)
    case cancelled
    case peerClosed
}

class WebSocket: WebSocketClient {
    private var socket: WebSocketKit.WebSocket?
    private let group: EventLoopGroup
    private let socketLock = NIOLock()
    private var connectionFuture: EventLoopFuture<Void>?
    private let request: URLRequest

    /// All WebSocket events are handled via this delegate.
    /// In order to receive data over the WebSocket you
    /// must assign a delegate.
    var delegate: WebSocketDelegate?

    /// Creates a WebSocket for the supplied ``URLRequest``.
    /// - NOTE: ``WebSocket/delegate`` must be set and  ``WebSocket/connect`` must
    ///      be called before the WebSocket will be fully initialized.
    init(request: URLRequest) {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.request = request
    }

    /// Attempt to establish the WebSocket connection with the
    /// endpoint supplied at initialization.
    /// - NOTE: You should assign a delegate to ``WebSocket`` prior to
    ///     calling this function so as not to miss any traffic.
    public func connect() {
        let headers = request.allHTTPHeaderFields ?? [:]
        _ = WebSocketKit.WebSocket.connect(
            to: request.url!,
            headers: HTTPHeaders(headers.map({ ($0, $1) })),
            on: group,
            onUpgrade: { [weak self] socket in
                guard let self else { return }
                self.socketLock.withLockVoid {
                    self.setupAllSocketHandlers(for: socket)
                    self.socket = socket
                }
                self.delegate?.didReceive(event: .connected(headers), client: self)
            }
        )
    }

    public func write(string: String, completion: (() -> ())? = nil) {
        schedule({ $0.send(string, promise: $1) }, completion: completion)
    }

    public func write(stringData: Data, completion: (() -> ())? = nil) {
        schedule({ $0.send(raw: stringData, opcode: .text, promise: $1) }, completion: completion)
    }

    public func write(data: Data, completion: (() -> ())? = nil) {
        schedule({ $0.send(raw: data, opcode: .binary, promise: $1) }, completion: completion)
    }

    public func write(ping: Data, completion: (() -> ())? = nil) {
        schedule({ $0.sendPing(ping, promise: $1) }, completion: completion)
    }

    public func write(pong: Data, completion: (() -> ())? = nil) {
        schedule({ $0.send(raw: pong, opcode: .pong, promise: $1) }, completion: completion)
    }

    func disconnect(closeCode: UInt16) {
        schedule({
            $0.close(code: WebSocketErrorCode(codeNumber: Int(closeCode)), promise: $1)
        }, completion: { [weak self] in
            guard let self else { return }
            self.delegate?.didReceive(event: .cancelled, client: self)
        })
    }

    /// Helper for calling the ``WebSocketKit/WebSocket`` functions since
    /// they all share similar scaffolding needs.
    private func schedule(_ closure: @escaping ((WebSocketKit.WebSocket, EventLoopPromise<Void>) -> Void), completion: (() -> Void)? = nil) {
        socketLock.withLock({
            if let socket {
                let promise = group.next().makePromise(of: Void.self)
                closure(socket, promise)
                _ = promise.futureResult.map({ completion?() })
            }
        })
    }

    /// Sets up all relevant handlers on socket events and routes them to the ``delegate`` as appropriate.
    /// - WARNING: Should only be called within the context of ``socketLock``
    private func setupAllSocketHandlers(for socket: WebSocketKit.WebSocket) {
        socket.onText({ [weak self] in
            guard let self else { return }
            self.delegate?.didReceive(event: .text($1), client: self)
        })

        socket.onBinary({ [weak self] in
            guard let self else { return }
            self.delegate?.didReceive(event: .binary(Data(buffer: $1)), client: self)
        })

        socket.onPong({ [weak self] in
            guard let self else { return }
            self.delegate?.didReceive(event: .pong(Data(buffer: $1)), client: self)
        })

        socket.onPing({ [weak self] in
            guard let self else { return }
            self.delegate?.didReceive(event: .ping(Data(buffer: $1)), client: self)
        })

        socket.onPing({ [weak self] in
            guard let self else { return }
            self.delegate?.didReceive(event: .ping(Data(buffer: $1)), client: self)
        })

        _ = socket.onClose.map({ [weak self] in
            guard let self else { return }
            guard let closeCode = socket.closeCode else {
                self.delegate?.didReceive(event: .disconnected("no close code", 0), client: self)
                return
            }
            switch closeCode {
                case .unexpectedServerError:
                    self.delegate?.didReceive(event: .peerClosed, client: self)
                    fallthrough
                case .protocolError,
                        .unacceptableData,
                        .dataInconsistentWithMessage,
                        .policyViolation,
                        .messageTooLarge,
                        .missingExtension:
                    self.delegate?.didReceive(event: .error(closeCode), client: self)
                case .normalClosure, .goingAway:
                    self.delegate?.didReceive(event: .disconnected(closeCode.text, 0), client: self)
                case let .unknown(code):
                    self.delegate?.didReceive(event: .disconnected(closeCode.text, code), client: self)
                    self.delegate?.didReceive(event: .error(closeCode), client: self)
                    if code == 1006 { // Ping timeout
                        self.delegate?.didReceive(event: .viabilityChanged(true), client: self)
                        self.delegate?.didReceive(event: .reconnectSuggested(true), client: self)
                    }
            }
        })
    }
}

extension WebSocketClient {
    /// Disconnects from a socket using one of the close codes in the GraphQL WS specification.
    func disconnect(closeCode: CloseCode) {
        self.disconnect(closeCode: closeCode.rawValue)
    }
}



// MARK: - Data
private extension Data {

    /// Creates a `Data` from a given `ByteBuffer`. The entire readable portion of the buffer will be read.
    /// - parameter buffer: The buffer to read.
    init?(buffer: ByteBuffer, byteTransferStrategy: ByteBuffer.ByteTransferStrategy = .automatic) {
        var buffer = buffer
        guard let data = buffer.readData(
            length: buffer.readableBytes,
            byteTransferStrategy: byteTransferStrategy
        ) else { return nil }
        self = data
    }

}

private extension WebSocketErrorCode {
    var text: String { "\(self)" }
}

extension WebSocketErrorCode: Error {}
