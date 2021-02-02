import Foundation

public extension CodingKey {
    /// Tells whether a CodingKey represents GraphQL's typename meta field.
    var isTypenameKey: Bool {
        stringValue == "__typename"
    }
}
