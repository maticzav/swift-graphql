import SwiftUI

struct FeedView: View {
    @ObservedObject var vm: FeedViewModel = FeedViewModel()
    
    var user: User
    
    var body: some View {
        UserView(user: user)
            .padding()
        
        List {
            ForEach(vm.repositories) { repo in
                Link(destination: repo.url) {
                    RepositoryView(repo: repo)
                }
                .padding(.horizontal)
            }
            .listRowSeparatorTint(.clear)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
        }
        .listStyle(.plain)
    }
}

// MARK: - Previews

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(user: User.preview)
    }
}
