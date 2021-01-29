/*
 Utility functions used for turning a scalar name into
 its mapped type.
 */

extension GraphQLCodegen.Options {
    /// Returns the mapped value of the scalar.
    func scalar(_ name: String) throws -> String {
        if let mapping = self.scalarMappings[name] {
            return mapping
        }
        throw ScalarError.unknown(name)
    }
}

enum ScalarError: Error {
    case unknown(String)
}
