import Foundation
import SwiftGraphQLClient
import SwiftUI


/// An application wrapper that lets you use SwiftUI bindings in child components.
public struct GraphQLContainer<Content: View>: View {
    
    /// An implementation of the GraphQL client that the SwiftUI bindings use.
    private var client: SwiftGraphQLClient.Client
    
    /// A function that renders the conent of the container.
    private var content: () -> Content
    
    init(client: Client, @ViewBuilder content: @escaping () -> Content) {
        self.client = client
        self.content = content
    }
    
    public var body: some View {
        content().environmentObject(client)
    }
}
