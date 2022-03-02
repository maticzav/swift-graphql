import Foundation

extension Field {
    
    /// A list of scalars that are referenced in the arguments and the returned type.
    public func scalars(schema: Schema) throws -> Set<ScalarType> {
        try self.returnTypeScalars(schema: schema).union(self.argsScalars(schema: schema))
    }
    
    // MARK: - Utils
    
    /// Returns scalars that appear in the arguments of the field.
    private func argsScalars(schema: Schema) throws -> Set<ScalarType> {
        Set(try args.flatMap { try $0.scalars(schema:schema ) })
    }
    
    /// Returns scalars related to the type returned by the field.
    private func returnTypeScalars(schema: Schema) throws -> Set<ScalarType> {
        let returnTypeName = self.type.namedType.name
        guard let namedType = schema.type(name: returnTypeName) else {
            throw ParsingError.unknownType(returnTypeName)
        }
        
        return try namedType.scalars(schema: schema)
    }
}

extension InputValue {
    /// A list of scalars that are referenced in the input fields and their descendants.
    public func scalars(schema: Schema) throws -> [ScalarType] {
        switch self.type.namedType {
        case .enum:
            return []
        case .scalar(let name):
            guard let scalar = schema.scalar(name: name) else {
                throw ParsingError.unknownScalar(name)
            }
            return [scalar]
        case .inputObject(let name):
            guard let object = schema.inputObject(name: name) else {
                throw ParsingError.unknownInputObject(name)
            }
            
            let scalars = try object.inputFields.flatMap {
                try $0.scalars(schema: schema)
            }
            return scalars
        }
    }
}
