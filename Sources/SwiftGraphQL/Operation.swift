/*
 RootOperation denotes a top-level query object.
 
 Only the top Query and Mutation conform to this protocol
 so that the end user cannot make an invalid request.
*/

public protocol GraphQLOperation {
    static var operation: String { get }
}
public protocol GraphQLQuery: GraphQLOperation {}
public protocol GraphQLMutation: GraphQLOperation {}
public protocol GraphQLSubscription: GraphQLOperation {}

extension GraphQLQuery {
    public static var operation: String { "query" }
}
extension GraphQLMutation {
    public static var operation: String { "mutation" }
}
extension GraphQLSubscription {
    public static var operation: String { "subscription" }
}

