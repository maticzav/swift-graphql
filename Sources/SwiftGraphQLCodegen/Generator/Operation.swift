import Foundation
import GraphQLAST
import SwiftAST

extension GraphQLAST.Operation: BlockProtocol {
    public var block: Block {
        var code = [String]()

        code.append("extension Objects.\(type.name.pascalCase): \(self.protocol) {")
        code.append("    static var operation: String { \"\(self.operation)\" } ")
        code.append("}")

        
        return .blocks([])
    }
    
    private var operation: String {
        switch self {
        case .query:
            return "query"
        case .mutation:
            return "mutation"
        case .subscription:
            return "subscription"
        }
    }

    private var `protocol`: String {
        switch self {
        case .query, .mutation:
            return "GraphQLHttpOperation"
        case .subscription:
            return "GraphQLWebSocketOperation"
        }
    }
}
