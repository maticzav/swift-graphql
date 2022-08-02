import Foundation

struct User: Identifiable, Equatable {
    var id: String
    var username: String
    var url: URL?
    
    var avatar: URL
    
    static let preview = User(
        id: "user-mckid",
        username: "maticzav",
        avatar: URL(string: "https://avatars.githubusercontent.com/u/3924224?u=66a57881d09c312bef538bdb142eb2a01cb20380&v=4")!
    )
}
