import Combine
import Foundation
import GraphQL
import SwiftGraphQL
import SwiftUI

protocol GraphQLClient {
    
    /// Log a debug message.
    func log(message: String) -> Void
}




// MARK: - Client

public class Client: GraphQLClient {
    private var exchanges: [Exchange]
    
    init(exchanges: [Exchange]) {
        self.exchanges = exchanges
        
        
    }
    
    // MARK: - Methods
    
    func log(message: String) {
        print(message)
    }
    
}

// MARK: - Binidings

