import GraphQLAST

extension Schema {
    
    /// Returns a list of missing scalars that are used in the schema, but not supported in
    /// the provided scalar map.
    public func missing(scalars: ScalarMap) throws -> [String] {
        return try self.usedScalars().filter { !scalars.supported.contains($0) }
    }
}
