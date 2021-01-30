import Foundation

extension CodingKey {
    /// Tells whether a CodingKey represents GraphQL's typename meta field.
    public var isTypenameKey: Bool {
        self.stringValue == "__typename"
    }
}
