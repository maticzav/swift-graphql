import Combine
import Foundation
import GraphQL
import SwiftGraphQL
import SwiftUI

/// Specifies the minimum requirements of a client to support the execution of queries
/// composed using SwiftGraphQL.
public protocol GraphQLClient {
    
    /// Log a debug message.
    func log(message: String) -> Void
    
    /// Executes an operation by sending it down the exchange pipeline.
    ///
    /// - Returns: A publisher that emits all related exchange results.
    func executeRequestOperation(operation: Operation) -> AnyPublisher<OperationResult, Never>
}

// MARK: - Client

public class Client: GraphQLClient {
    
    /// Central subject publisher responsible for accepting operation execution requests.
    private var subject = PassthroughSubject<Operation, Never>()
    
    /// Stream of results that may be used as the base for sources.
    private var results: AnyPublisher<OperationResult, Never>
    
    /// Stream of results related to a given operation.
    public typealias Source = AnyPublisher<OperationResult, Never>
    
    /// Map of currently active sources identified by their operation identifier.
    private var active: [String: Source]
    
    /// List of opeartions waiting to be executed.
    private var queue: [String]
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    /// Creates a new client that processes requests using provided exchanges.
    ///
    /// - parameter exchanges: List of exchanges that process each operation left-to-right.
    ///
    init(exchanges: [Exchange] = []) {
        let exchange = ComposeExchange(exchanges: exchanges)
        let operations = subject.share().eraseToAnyPublisher()
        
        let noop = Empty<OperationResult, Never>().eraseToAnyPublisher()
        self.results = noop
        
        self.active = [:]
        self.queue = []
        
        self.results = exchange.register(
            client: self,
            operations: operations,
            next: { _ in noop }
        )
        
        // We start the chain to make sure the data is always flowing through the pipeline.
        // This is important to make sure all exchanges receive information when necessary
        // even if there are no active subscribers outside the client.
        self.results
            .sink { _ in }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Methods
    
    /// Log a debug message.
    public func log(message: String) {
        print(message)
    }
    
    /// Executes an operation by sending it down the exchange pipeline.
    public func executeRequestOperation(operation: Operation) -> Source {
        
        // Mutations shouldn't have open sources because they are executed once and "discarded".
        if operation.kind == .mutation {
            return createResultSource(operation: operation)
        }
        
        let source: Source
        if let existingSource = active[operation.id] {
            source = existingSource
        } else {
            source = createResultSource(operation: operation)
            active[operation.id] = source
        }
        
        
        
        
        return source
    }
    
    /// Defines how result streams are created.
    private func createResultSource(operation: Operation) -> Source {
        let source = self.results
            .filter { $0.operation.kind == operation.kind && $0.operation.id == operation.id }
            .eraseToAnyPublisher()
        
        if operation.kind == .mutation {
            return source.first().eraseToAnyPublisher()
        }
        
        return source
    }
}

// MARK: - Selection Bindings

extension GraphQLClient {
    
    /// Turns selection into a request operation.
    public func createRequestOperation<Type, TypeLock>(
        for selection: Selection<Type, TypeLock>,
        as operationName: String? = nil,
        url request: URLRequest,
        policy: Operation.Policy
    ) -> Operation where TypeLock: GraphQLOperation {
        Operation(
            id: UUID().uuidString,
            kind: TypeLock.operationKind,
            request: request,
            policy: policy,
            types: Array(selection.types),
            args: selection.encode(operationName: operationName)
        )
    }
    
    /// Executes a query against the client and returns a publisher that emits values from relevant exchanges.
    public func executeQuery<Type, TypeLock>(
        for selection: Selection<Type, TypeLock>,
        as operationName: String? = nil,
        url request: URLRequest,
        policy: Operation.Policy
    ) -> AnyPublisher<OperationResult, Never> where TypeLock: GraphQLHttpOperation {
        let operation = self.createRequestOperation(
            for: selection,
           as: operationName,
           url: request,
           policy: policy
        )
        return self.executeRequestOperation(operation: operation)
    }
    
    /// Executes a mutation against the client and returns a publisher that emits values from relevant exchanges.
    public func executeMutation<Type, TypeLock>(
        for selection: Selection<Type, TypeLock>,
        as operationName: String? = nil,
        url request: URLRequest,
        policy: Operation.Policy
    ) -> AnyPublisher<OperationResult, Never> where TypeLock: GraphQLHttpOperation {
        let operation = self.createRequestOperation(
            for: selection,
           as: operationName,
           url: request,
           policy: policy
        )
        return self.executeRequestOperation(operation: operation)
    }
    
    /// Executes a mutation against the client and returns a publisher that emits values from relevant exchanges.
    public func executeSubscription<Type, TypeLock>(
        to selection: Selection<Type, TypeLock>,
        as operationName: String? = nil,
        url request: URLRequest,
        policy: Operation.Policy
    ) -> AnyPublisher<OperationResult, Never> where TypeLock: GraphQLWebSocketOperation {
        let operation = self.createRequestOperation(
            for: selection,
           as: operationName,
           url: request,
           policy: policy
        )
        return self.executeRequestOperation(operation: operation)
    }
}

