import Foundation

/// Structure that maps GraphQL scalars to their Swift types.
public struct ScalarMap: Equatable {
    /// Dictionary of Swift scalars indexed by the scalar name in GraphQL schema.
    private var definitions: [String: String]
    
    public init() {
        self.definitions = [:]
    }
    
    public init(scalars: [String: String]) {
        self.definitions = scalars
    }
    
    /// Converts a scalar from the GraphQL schema to a Swift type.
    func scalar(_ name: String) throws -> String {
        if let mapping = self.definitions[name] {
            return mapping
        }
        
        if let mapping = ScalarMap.builtin[name] {
            return mapping
        }
        
        return "AnyCodable"
    }
    
    /// List of GraphQL scaars that the scalar map supports.
    var supported: Set<String> {
        let keys = Array(self.definitions.keys) + Array(ScalarMap.builtin.keys)
        let scalars = Set<String>(keys)
        
        return scalars
    }
    
    /// A map of built-in scalars where Swift types are indexed by the GraphQL type.
    static private var builtin: [String: String] {
        [
            "ID": "String",
            "String": "String",
            "Int": "Int",
            "Boolean": "Bool",
            "Float": "Double",
        ]
    }
}
