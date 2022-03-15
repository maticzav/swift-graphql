import Foundation
import GraphQLAST

/// A type that is passed down to every field that requires contextual information.
public struct Context {
    
    /// Currently processed schema.
    var schema: Schema
    
    /// Available scalars on the client.
    var scalars: ScalarMap
}
