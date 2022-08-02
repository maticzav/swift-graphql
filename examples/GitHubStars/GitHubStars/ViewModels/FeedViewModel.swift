import Foundation

class FeedViewModel: ObservableObject {
    @Published var repositories: [Repository]
    
    init() {
        self.repositories = []
        
        AuthClient.state
            .filter { state in
                if case .authenticated = state {
                    return true
                }
                return false
            }
            .flatMap { _ in NetworkClient.shared.query(Repository.starred) }
            .receive(on: RunLoop.main)
            .map { result -> [Repository] in
                switch result.result {
                case .ok(let data):
                    return data
                default:
                    return []
                }
            }
            .assign(to: &self.$repositories)
    }
}
