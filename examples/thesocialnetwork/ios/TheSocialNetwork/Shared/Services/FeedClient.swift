import Combine
import Foundation

enum FeedClient {
    
    /// Publisher that emits the number of unread posts.
    public static var unread: AnyPublisher<Int, Never> {
        self.client.$posts.eraseToAnyPublisher()
    }
    
    private static var client = Client()
    
    internal class Client: ObservableObject {
        
        /// Number of posts that the client hasn't read yet.
        @Published var posts: Int
        
        init() {
            self.posts = 0
            
            NetworkClient.shared
                .subscribe(to: Message.unread)
                .map { result -> Int in
                    switch result.result {
                    case .ok(let data):
                        return data
                    default:
                        return 0
                    }
                    
                }
                .assign(to: &self.$posts)
        }
    }
}
