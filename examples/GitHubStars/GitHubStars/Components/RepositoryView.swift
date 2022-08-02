import Foundation
import SwiftUI

struct RepositoryView: View {
    
    /// Repository that this view is presenting.
    var repo: Repository
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(repo.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                
                Spacer()
                
                Label {
                    Text("\(repo.stars)")
                        .bold()
                } icon: {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.yellow)
                }
            }
            
            if let description = repo.description {
                Text(description)
                    .padding(.bottom, 8)
            }
            
            UserView(user: repo.owner)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.thinMaterial)
        .cornerRadius(8)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Previews


struct RepositoryView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoryView(repo: Repository.preview)
            .padding()
    }
}

