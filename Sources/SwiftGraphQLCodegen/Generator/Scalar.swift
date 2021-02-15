import Foundation

/*
 This file contains functions that we use to pass scalars around
 the generator functions.
 */

public typealias ScalarMap = [String: String]

extension ScalarMap {
    func scalar(_ name: String) throws -> String {
        if let mapping = self[name] {
            return mapping
        }
        throw GraphQLCodegenError.unknownScalar(name)
    }
}

extension ScalarMap {
    /// A map of built-in scalars.
    static var builtin: ScalarMap {
        [
            "ID": "String",
            "String": "String",
            "Int": "Int",
            "Boolean": "Bool",
            "Float": "Double",
        ]
    }
}
