import Foundation

extension NamedType {
    
    /// Returns a list of scalars referenced by a named type and its descendant types.
    public func scalars(schema: Schema) throws -> Set<String> {
        switch self {
        case .scalar(let scalar):
            return [scalar.name]
        case .enum:
            return []
        case .union(let union):
            let referencedObjects: [ObjectType] = try union.possibleTypes.map { ref in
                guard let object = schema.object(name: ref.name) else {
                    throw ParsingError.unknownObject(ref.name)
                }
                return object
            }
            
            let scalars = try referencedObjects.flatMap { object in
                try object.fields.flatMap { try $0.scalars(schema:schema) }
            }
            return Set(scalars)
        case .inputObject(let input):
            return Set(try input.inputFields.flatMap { try $0.scalars(schema: schema) })
        case .object(let object):
            return Set(try object.fields.flatMap { try $0.scalars(schema:schema) })
        case .interface(let interface):
            let referencedObjects: [ObjectType] = try interface.possibleTypes.map { ref in
                guard let object = schema.object(name: ref.name) else {
                    throw ParsingError.unknownObject(ref.name)
                }
                return object
            }
            
            let scalars = try referencedObjects.flatMap { object in
                try object.fields.flatMap { try $0.scalars(schema:schema) }
            }
            return Set(scalars)
        }
    }
}
