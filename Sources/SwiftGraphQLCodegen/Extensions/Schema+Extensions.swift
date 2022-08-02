import GraphQLAST

extension Schema {
    
    /// Returns a list of missing scalars that are used in the schema, but not supported in
    /// the provided scalar map.
    public func missing(from scalars: ScalarMap) throws -> [String] {
        let missing = self.scalars.filter { !scalars.supported.contains($0.name) }
        return missing.map { $0.name }
    }
}
