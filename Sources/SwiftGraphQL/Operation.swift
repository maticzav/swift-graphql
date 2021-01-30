/*
 RootOperation denotes a top-level query object.
 
 Only the top Query and Mutation conform to this protocol
 so that the end user cannot make an invalid request.
*/

public protocol GraphQLOperation {
    static var operation: String { get }
}

public protocol GraphQLHttpOperation: GraphQLOperation {}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol GraphQLWebSocketOperation: GraphQLOperation {}
