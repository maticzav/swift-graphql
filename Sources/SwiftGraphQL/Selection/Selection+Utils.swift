import Foundation
import GraphQL

protocol TypeNameIdentifiable {
    /// Returns the name of the structure as described in the schema.
    var typename: String { get }
}

