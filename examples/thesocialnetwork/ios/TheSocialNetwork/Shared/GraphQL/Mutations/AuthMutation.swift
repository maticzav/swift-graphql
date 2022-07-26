import Foundation
import SwiftGraphQL

extension User {
    
    static func login(username: String, password: String) -> Selection.Mutation<String?> {
        let selection = Selection.AuthPayload<String?> {
            try $0.on(
                authPayloadSuccess: Selection.AuthPayloadSuccess<String?> {
                    try $0.token()
                },
                authPayloadFailure: Selection.AuthPayloadFailure<String?> { _ in
                    nil
                }
            )
        }
        
        return Selection.Mutation<String?> {
            try $0.login(username: username, password: password, selection: selection)
        }
    }
}
