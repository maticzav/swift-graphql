import RxSwiftCombine
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
            .map { res in res.data }
            .catch({ _ in Just([]) })
            .assign(to: &self.$repositories)
    }
}
