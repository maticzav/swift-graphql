import Foundation
import SwiftGraphQL

extension Repository {
    static let selection = Selection.Repository<Repository> {
        let id = try $0.id()
        let name = try $0.name()
        let description = try $0.description()
        let url = try $0.url()
        let stars = try $0.stargazerCount()
        
        let owner = try $0.owner(selection: Selection.RepositoryOwner<User> {
            try $0.on(
                organization: User.organization,
                user: User.selection
            )
        })
        
        return Repository(
            id: id,
            name: name,
            description: description,
            url: url,
            stars: stars,
            owner: owner
        )
    }
    
    /// Returns a list of repositories that the viewer has starred.
    static let starred = Selection.Query<[Repository]> {
        let selection = Selection.User<[Repository]> {
            let order = InputObjects.StarOrder(field: Enums.StarOrderField.starredAt, direction: Enums.OrderDirection.desc)
            
            return try $0.starredRepositories(orderBy: ~order, selection: Selection.StarredRepositoryConnection<[Repository]> {
                try $0.nodes(selection: Repository.selection.nonNullOrFail.list.nonNullOrFail)
            })
        }
        
        return try $0.viewer(selection: selection)
    }
}
