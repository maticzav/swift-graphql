import Combine
import Foundation
import GraphQL

#if canImport(SwiftGraphQL)
import SwiftGraphQL

/// Extensions to the core implementation that connect SwiftGraphQL's Selection to the execution
/// mechanisms of the client.
extension GraphQLClient {
    
    /// Turns selection into a request operation.
    private func createRequestOperation<T, TypeLock>(
        for selection: Selection<T, TypeLock>,
        as operationName: String? = nil,
        url request: URLRequest? = nil,
        policy: Operation.Policy
    ) -> Operation where TypeLock: GraphQLOperation {
        Operation(
            id: UUID().uuidString,
            kind: TypeLock.operationKind,
            request: request ?? self.request,
            policy: policy,
            types: Array(selection.types),
            args: selection.encode(operationName: operationName)
        )
    }
    
    // MARK: - Executors
    
    /// Executes a query against the client and returns a publisher that emits values from relevant exchanges.
    public func executeQuery<T, TypeLock>(
        for selection: Selection<T, TypeLock>,
        as operationName: String? = nil,
        url request: URLRequest? = nil,
        policy: Operation.Policy
    ) -> AnyPublisher<OperationResult, Never> where TypeLock: GraphQLHttpOperation {
        let operation = self.createRequestOperation(
            for: selection,
            as: operationName,
            url: request,
            policy: policy
        )
        return self.execute(operation: operation)
    }
    
    /// Executes a mutation against the client and returns a publisher that emits values from relevant exchanges.
    public func executeMutation<T, TypeLock>(
        for selection: Selection<T, TypeLock>,
        as operationName: String? = nil,
        url request: URLRequest? = nil,
        policy: Operation.Policy
    ) -> AnyPublisher<OperationResult, Never> where TypeLock: GraphQLHttpOperation {
        let operation = self.createRequestOperation(
            for: selection,
            as: operationName,
            url: request,
            policy: policy
        )
        return self.execute(operation: operation)
    }
    
    /// Executes a mutation against the client and returns a publisher that emits values from relevant exchanges.
    public func executeSubscription<T, TypeLock>(
        of selection: Selection<T, TypeLock>,
        as operationName: String? = nil,
        url request: URLRequest? = nil,
        policy: Operation.Policy
    ) -> AnyPublisher<OperationResult, Never> where TypeLock: GraphQLWebSocketOperation {
        let operation = self.createRequestOperation(
            for: selection,
            as: operationName,
            url: request,
            policy: policy
        )
        return self.execute(operation: operation)
    }
    
    // MARK: - Decoders
    
    
    /// Executes a query and returns a stream of decoded values.
    public func query<T, TypeLock>(
        _ selection: Selection<T, TypeLock>,
        as operationName: String? = nil,
        request: URLRequest? = nil,
        policy: Operation.Policy = .cacheFirst
    ) -> AnyPublisher<DecodedOperationResult<T>, Error> where TypeLock: GraphQLHttpOperation {
        self.executeQuery(for: selection, as: operationName, url: request, policy: policy)
            .tryMap { result in try result.decode(selection: selection) }
            .eraseToAnyPublisher()
    }


    /// Executes a query request with given execution parameters.
    public func query<T, TypeLock>(
        _ selection: Selection<T, TypeLock>,
        as operationName: String? = nil,
        request: URLRequest? = nil,
        policy: Operation.Policy = .cacheFirst
    ) async throws -> DecodedOperationResult<T> where TypeLock: GraphQLHttpOperation {
        try await self.query(selection, as: operationName, request: request, policy: policy).first()
    }
    
    /// Executes a mutation and returns a stream of decoded values.
    public func mutate<T, TypeLock>(
        _ selection: Selection<T, TypeLock>,
        as operationName: String? = nil,
        request: URLRequest? = nil,
        policy: Operation.Policy = .cacheFirst
    ) -> AnyPublisher<DecodedOperationResult<T>, Error> where TypeLock: GraphQLHttpOperation {
        self.executeMutation(for: selection, as: operationName, url: request, policy: policy)
            .tryMap { result in try result.decode(selection: selection) }
            .eraseToAnyPublisher()
    }

    public func mutate<T, TypeLock>(
        _ selection: Selection<T, TypeLock>,
        as operationName: String? = nil,
        request: URLRequest? = nil,
        policy: Operation.Policy = .cacheFirst
    ) async throws -> DecodedOperationResult<T> where TypeLock: GraphQLHttpOperation {
        try await self.mutate(selection, as: operationName, request: request, policy: policy).first()
    }
    
    /// Creates a subscription stream of decoded values from the given query.
    public func subscribe<T, TypeLock>(
        to selection: Selection<T, TypeLock>,
        as operationName: String? = nil,
        request: URLRequest? = nil,
        policy: Operation.Policy = .cacheFirst
    ) -> AnyPublisher<DecodedOperationResult<T>, Error> where TypeLock: GraphQLWebSocketOperation {
        self.executeSubscription(of: selection, as: operationName, url: request, policy: policy)
            .tryMap { result in try result.decode(selection: selection) }
            .eraseToAnyPublisher()
    }
}

extension OperationResult {
    
    /// Decodes data in operation result using the selection decoder.
    fileprivate func decode<T, TypeLock>(
        selection: Selection<T, TypeLock>
    ) throws -> DecodedOperationResult<T> {
        let data = try selection.decode(raw: self.data)
        
        let result = DecodedOperationResult(
            operation: self.operation,
            data: data,
            errors: self.errors,
            stale: self.stale
        )
        
        return result
    }
}
#endif
