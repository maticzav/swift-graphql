import Foundation
import GraphQLAST

/*
 We represent enumerator values as strings. There's nothing
 special in here, just the generated code.
 */

extension EnumType {
    var declaration: String {
        """
        \(docs)
        enum \(name.pascalCase): String, CaseIterable, Codable {
        \(values)
        }
        """
    }
    
    private var values: String {
        enumValues.map { $0.declaration }.joined(separator: "\n")
    }
    
    private var docs: String {
        ""
    }
}

extension EnumValue {
    
    var declaration: String {
        """
        \(docs)
        \(availability)
        case \(name.camelCase.normalize) = "\(name)"
        """
    }
    
    private var docs: String {
        description.map { "/// \($0)" } ?? ""
    }
    

    private var availability: String {
        if isDeprecated {
            let message = deprecationReason ?? ""
            return "@available(*, deprecated, message: \"\(message)\")"
        }
        return ""
    }
}
