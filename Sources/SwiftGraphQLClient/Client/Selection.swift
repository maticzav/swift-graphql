import RxSwift
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
    ) -> Observable<OperationResult> where TypeLock: GraphQLHttpOperation {
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
    ) -> Observable<OperationResult> where TypeLock: GraphQLHttpOperation {
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
    ) -> Observable<OperationResult> where TypeLock: GraphQLWebSocketOperation {
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
    ) -> Observable<DecodedOperationResult<T>> where TypeLock: GraphQLHttpOperation {
        self.executeQuery(for: selection, as: operationName, url: request, policy: policy)
            .map { result in
                // NOTE: If there was an error during the execution, we want to raise it before running
                //       the decoder on the `data` which will most likely fail.
                if let error = result.error {
                    throw error
                }
                return try result.decode(selection: selection)
            }
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
    ) -> Observable<DecodedOperationResult<T>> where TypeLock: GraphQLHttpOperation {
        self.executeMutation(for: selection, as: operationName, url: request, policy: policy)
            .map { result in
                // NOTE: If there was an error during the execution, we want to raise it before running
                //       the decoder on the `data` which will most likely fail.
                if let error = result.error {
                    throw error
                }
                return try result.decode(selection: selection)
            }
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
    ) -> Observable<DecodedOperationResult<T>> where TypeLock: GraphQLWebSocketOperation {
        self.executeSubscription(of: selection, as: operationName, url: request, policy: policy)
            .map { result in
                // NOTE: If there was an error during the execution, we want to raise it before running
                //       the decoder on the `data` which will most likely fail.
                if let error = result.error {
                    throw error
                }
                return try result.decode(selection: selection)
            }
    }
}

extension OperationResult {
    
    /// Decodes data in operation result using the selection decoder.
    public func decode<T, TypeLock>(selection: Selection<T, TypeLock>) throws -> DecodedOperationResult<T> {
        // NOTE: One of four things might happen as described in http://spec.graphql.org/October2021/#sec-Response-Format:
        //   1. execution was successful: `data` field is present, `error` is not;
        //   2. error was raised before the execution began: `error` field is present, `data` is not;
        //   3. error was raised during exeuction: `error` field is present, `data` is nil;
        //   4. field error occurred: both `data` and `error` fiels are present.
        // Of the above four cases, we can be confident that the contract hasn't been broken in cases
        // 1) and 4). In other cases, it's possible that even though the resolver expected a value it encountered
        // an error and received `nil` instead. In such cases, we need to terminate the pipeline altogether.
        
        switch (self.data.value) {
        #if canImport(Foundation)
        case is NSNull, is Void, Optional<AnyDecodable>.none:
            if let error = self.error {
                throw error
            }
            // NOTE: This should never happen if the server follows the GraphQL Specification!
            throw OperationError.missingBothDataAndErrorFields
        #else
        case is Void, Optional<AnyDecodable>.none:
            if let error = self.error {
                throw error
            }
            throw OperationError.missingBothDataAndErrorFields
        #endif
                
        default:
            let data = try selection.decode(raw: self.data)
                    
            let result = DecodedOperationResult(
                operation: self.operation,
                data: data,
                error: self.error,
                stale: self.stale
            )
                    
            return result
        }
        
        
    }
}

public enum OperationError: Error {
    case missingBothDataAndErrorFields
}

#endif

