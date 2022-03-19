import Foundation
import GraphQLAST

extension Schema {
    
    /// Returns all scalars that are used in the schema.
    func scalars() throws -> Set<String> {
        var set = Set<String>()
        
        for type in self.types {
            set = set.union(try type.scalars(schema: self))
        }
        
        return set
    }
    
    /// Filters the schema so it only uses supported scalars.
    ///
    /// - parameter scalars: List of supported scalars as named in the GraphQL schema.
    ///
    func filter(with scalars: [String]) throws -> Schema {
        let types = try self.types.compactMap { type -> NamedType? in
            switch type  {
            case .scalar(let scalar):
                if scalars.contains(scalar.name) {
                    return type
                }
            case .object(let object):
                if object.isInternal {
                    return type
                }
                
                let fields = try object.fields.filter { try $0.isSupported(in: self, with: scalars) }
                let filtered = ObjectType(
                    name: object.name,
                    description: object.description,
                    fields: fields,
                    interfaces: object.interfaces
                )
                
                return .object(filtered)
            case .interface(let interface):
                if interface.isInternal {
                    return type
                }
                
                let fields = try interface.fields.filter { try $0.isSupported(in: self, with: scalars) }
                let filtered = InterfaceType(
                    name: interface.name,
                    description: interface.description,
                    fields: fields,
                    interfaces: interface.interfaces,
                    possibleTypes: interface.possibleTypes
                )
                
                return .interface(filtered)
            case .inputObject(let input):
                if input.isInternal {
                    return type
                }
                
                let fields = try input.inputFields.filter { try $0.isSupported(in: self, with: scalars) }
                let filtered = InputObjectType(
                    name: input.name,
                    description: input.description,
                    fields: fields
                )
                
                return .inputObject(filtered)
            case .union, .enum:
                return type
            }
            
            return nil
        }
        
        let schema = Schema(
            types: types,
            query: self.query.type.name,
            mutation: self.mutation?.type.name,
            subscription: self.subscription?.type.name
        )
        return schema
    }
}

extension Field {
    /// Tells whether all scalars used in the field are supported.
    ///
    /// - parameter supportedScalars: List of scalars as named in the schema that are supported.
    func isSupported(in schema: Schema, with supportedScalars: [String]) throws -> Bool {
        let usedScalars = try self.scalars(schema: schema)
        
        return usedScalars.isSubset(of: supportedScalars)
    }
}

extension InputValue {
    /// Tells whether all scalars used in the field are supported.
    ///
    /// - parameter supportedScalars: List of scalars as named in the schema that are supported.
    func isSupported(in schema: Schema, with supportedScalars: [String]) throws -> Bool {
        let usedScalars = try self.scalars(schema: schema)
        
        return usedScalars.isSubset(of: supportedScalars)
    }
}

