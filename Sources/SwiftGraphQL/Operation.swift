/*
 RootOperation denotes a top-level query object.
 
 Only the top Query and Mutation conform to this protocol
 so that the end user cannot make an invalid request.
*/

public protocol GraphQLOperation {
    static var operation: GraphQLOperationType { get }
}
