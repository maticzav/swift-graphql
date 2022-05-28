import Foundation

extension Field {
    
    /// A list of scalars that are referenced in the arguments and the returned type.
    public func scalars(schema: Schema) throws -> Set<String> {
        let scalarsInArguments = try self.argsScalars(schema: schema)
        let scalarsInReturnType = try self.returnTypeScalars(schema: schema)
        
        return scalarsInArguments.union(scalarsInReturnType)
    }
    
    // MARK: - Utils
    
    /// Returns scalars that appear in the arguments of the field.
    private func argsScalars(schema: Schema) throws -> Set<String> {
        Set(try self.args.flatMap { try $0.scalars(schema:schema) })
    }
    
    /// Returns scalars related to the type returned by the field.
    private func returnTypeScalars(schema: Schema) throws -> Set<String> {
        let returnTypeName = self.type.namedType.name
        guard let namedType = schema.type(name: returnTypeName) else {
            throw ParsingError.unknownType(returnTypeName)
        }
        
        return try namedType.scalars(schema: schema)
    }
}

extension InputValue {
    /// A list of scalars that are referenced in the input fields and their descendants.
    public func scalars(schema: Schema, path: Set<String> = Set()) throws -> Set<String> {
        switch self.type.namedType {
        case .enum:
            return Set()
        case .scalar(let name):
            guard let scalar = schema.scalar(name: name) else {
                throw ParsingError.unknownScalar(name)
            }
            return Set([scalar.name])
        case .inputObject(let name):
            // We create a path to prevent trapping ourselves into
            // infinite recursive loops. Here we note that if we already
            // examined an input object and got back again there are no
            // new scalars that haven't been examined yet.
            guard !path.contains(name) else {
                return Set()
            }
            
            guard let object = schema.inputObject(name: name) else {
                throw ParsingError.unknownInputObject(name)
            }
            
            let newPath = path.inserting(name)
            let scalars = try object.inputFields.flatMap {
                try $0.scalars(schema: schema, path: newPath)
            }
            
            return Set(scalars)
        }
    }
}
