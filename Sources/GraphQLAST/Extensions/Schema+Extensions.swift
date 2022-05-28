import Foundation

public extension Schema {
    
    /// Returns all scalars that are used in the schema.
    func usedScalars() throws -> Set<String> {
        try self.types.reduce(Set()) { acc, type in
            acc.union(try type.scalars(schema: self))
        }
    }
}
