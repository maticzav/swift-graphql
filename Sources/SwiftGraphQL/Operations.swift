import Foundation

/*
 Contains types used to annotate top-level queries which can be
 built up using generated functions.
 
 Only the top Query and Mutation conform to these protocols
 so that the end user cannot make an invalid request.
*/

public protocol GraphQLRootQuery {}
public protocol GraphQLRootMutation {}
