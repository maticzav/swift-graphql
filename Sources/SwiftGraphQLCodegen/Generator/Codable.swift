import Foundation
import GraphQLAST

/*
 Codable is responsible for generating an intermediate type that
 generated code uses to decode the response.

 We first decode the key that references a result and use the type
 engraved in the alias to further decode the result. The result is
 saved into a HashMap structure that groups fields with the same type
 and extract a dictionary of results from it.
 */

protocol Structure {
    var fields: [Field] { get }
    var possibleTypes: [ObjectRef] { get }
}

extension Structure {
    func structure(name: String) -> String {
        let properties = fields
            .map { $0.declaration }
            .joined(separator: "\n")
        
        return """
        struct \(name) {
            let __typename: TypeName
            \(properties)

            \(possibleTypes.typename)
        }
        """
    }
    
    var decoder: String {
        ""
    }
}

extension Collection where Element == ObjectRef {
    fileprivate var typename: String {
        let types = self
            .map { "case \($0.name.camelCase.normalize) = \"\($0.name)\"" }
            .joined(separator: "\n")
        
        return """
        enum TypeName: String, Codable {
        \(types)
        }
        """
    }
}

extension Collection where Element == Field {
    var decoder: String {
        let cases: String = self
            .map { $0.decoder }
            .joined(separator: "\n")
        let mappings: String = self
            .map { "self.\($0.name.camelCase) = map[\"\($0.name.camelCase)\"]" }
            .joined(separator: "\n")
        
        return """
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

            var map = HashMap()
            for codingKey in container.allKeys {
                if codingKey.isTypenameKey { continue }

                let alias = codingKey.stringValue
                let field = GraphQLField.getFieldNameFromAlias(alias)

                switch field {
                \(cases)
                }
            }

            self.__typename = try container.decode(TypeName.self, forKey: DynamicCodingKeys(stringValue: \"__typename\")!)

            \(mappings)
        }
        """
    }
}


extension Field {
    fileprivate var declaration: String {
        let type = generateDecoderType(try generateOutputType(ref: type.namedType), for: type.nonNullable)
        return "let \($0.name.camelCase.normalize): [String: \(type)]"
    }
    
    fileprivate var decoder: String {
        let type = try generateOutputType(ref: type.namedType)
        let decoderType = generateDecoderType(type, for: type.nullable)
        
        return """
        case \"\(name.camelCase)\":
            if let value = try container.decode(\(decoderType).self, forKey: codingKey) {
                map.set(key: field, hash: alias, value: value as Any)
            }
        """
    }
}
