import Combine
import GraphQL
import SwiftGraphQL
import SwiftUI

@propertyWrapper struct Query<Type: Decodable, TypeLock: GraphQLHttpOperation & Decodable>: DynamicProperty {
    
    struct Result {
        var data: Type?
        var errors: [GraphQLError]?
        var fetching: Bool
    }
    
    @State private var result = Result(
        data: nil,
        errors: nil,
        fetching: false
    )
    
    private var selection: Selection<Type, TypeLock>
    
    init(query selection: Selection<Type, TypeLock>) {
        self.selection = selection
    }
    
    var wrappedValue: Result {
        get {
            return result
        }
        set {}
    }
}

struct Foo: View {
    
    @Query(query: query) private var query: Query<String, Objects.Query>.Result
    
    var body: some View {
        EmptyView()
    }
}
