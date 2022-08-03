import Foundation

struct Repository: Identifiable {
    var id: String
    var name: String
    var description: String?
    
    var url: URL
    var stars: Int
    
    let owner: User
    
    static let preview = Repository(
        id: "repo-mockid",
        name: "swift-graphql",
        description: "A GraphQL client that lets you forget about GraphQL.",
        url: URL(string: "https://github.com/maticzav/swift-graphql")!,
        stars: 459,
        owner: User.preview
    )
}
