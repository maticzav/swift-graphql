import Foundation

/*
    Contains types used to annotate top-level queries which can be
    built up using generated functions.
*/

public enum Operation {
    public struct Query: Decodable {}
    public struct Mutation: Decodable {}
    public struct Subscription: Decodable {}
}

public typealias RootQuery = Operation.Query
public typealias RootMutation = Operation.Mutation
public typealias RootSubscription = Operation.Subscription
