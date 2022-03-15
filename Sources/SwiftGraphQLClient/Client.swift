import Combine
import Foundation
import GraphQL
import SwiftGraphQL
import SwiftUI

public protocol GraphQLClient {
    
    /// Log a debug message.
    func log(message: String) -> Void
    
    /// Executes an operation by sending it down the exchange pipeline.
    ///
    /// - Returns: A publisher that emits all related exchange results.
    func executeRequestOperation(operation: Operation) -> AnyPublisher<OperationResult, Never>
}




//// MARK: - Client
//
//public class Client: GraphQLClient {
//    
//    /// List of exchanges that should be used in the process of execution.
//    private var exchanges: [Exchange]
//    
//    init(exchanges: [Exchange]) {
//        self.exchanges = exchanges
//        
//        
//    }
//    
//    // MARK: - Methods
//    
//    public func log(message: String) {
//        print(message)
//    }
//    
//}

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
    public func query<Type, TypeLock>(
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
    public func mutate<Type, TypeLock>(
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
    public func subscribe<Type, TypeLock>(
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

