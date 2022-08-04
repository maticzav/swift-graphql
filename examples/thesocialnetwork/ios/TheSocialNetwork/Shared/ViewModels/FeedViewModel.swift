import Combine
import Foundation

class FeedViewModel: ObservableObject {
    
    /// Content of the new message that the user is composing.
    @Published var message: String
    
    /// Messages in the current feed.
    @Published var feed: [Message]
    
    /// Number of unread posts.
    @Published var unread: Int
    
    init() {
        self.message = ""
        self.feed = []
        self.unread = 0
        
        FeedClient.unread.assign(to: &self.$unread)
        
        self.refresh()
    }
    
    private var cancellable: AnyCancellable?
    
    /// Post a message with given content to the feed.
    func post() -> Void {
        guard self.message.count > 3 else {
            return
        }
        
        let mutation = Message.post(message: self.message)
        self.message = ""
        
        self.cancellable = NetworkClient.shared.mutate(mutation)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { result in })
    }
    
    /// Refreshes the feed with new data.
    func refresh() {
        NetworkClient.shared.query(Message.feed)
            .receive(on: RunLoop.main)
            .map { result in result.data }
            .catch({ err in
                Just([])
            })
            .assign(to: &self.$feed)
    }
}
