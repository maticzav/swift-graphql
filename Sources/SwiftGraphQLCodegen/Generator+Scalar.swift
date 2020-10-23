extension GraphQLCodegen.Options {
    /// Returns the mapped value of the scalar.
    func scalar(_ name: String) -> String {
        self.scalarMappings[name] ?? name
    }
}
