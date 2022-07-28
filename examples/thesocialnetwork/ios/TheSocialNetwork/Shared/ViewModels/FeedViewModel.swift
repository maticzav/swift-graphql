import Combine
import Foundation

class FeedViewModel: ObservableObject {
    @Published var message: String
    @Published var feed: [Message]
    
    init() {
        self.message = ""
        self.feed = []
        
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
            .sink { result in
                
            }
    }
    
    /// Refreshes the feed with new data.
    func refresh() {
        NetworkClient.shared.query(Message.feed)
            .receive(on: RunLoop.main)
            .map { result in
                guard case let .ok(data) = result.result else {
                    return []
                }
                
                return data
            }
            .assign(to: &self.$feed)
    }
}
