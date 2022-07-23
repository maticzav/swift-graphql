import Foundation

/*
 This file contains functions that we use to pass scalars around
 the generator functions.
 */

/// Dictionary of Swift scalars indexed by the scalar name in GraphQL schema.
public typealias ScalarMap = [String: String]

extension ScalarMap {
    /// Converts a scalar from the GraphQL schema to a Swift type.
    func scalar(_ name: String) throws -> String {
        if let mapping = self[name] {
            return mapping
        }
        return "AnyCodable"
    }
    
    /// List of GraphQL scalars that the scalar map supports.
    var supported: [String] {
        Array(self.keys)
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
