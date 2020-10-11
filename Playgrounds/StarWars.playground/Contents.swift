import Foundation
import SwiftGraphQLCodegen

/* Download the schema. */
let endpoint = URL(string: "https://elm-graphql.herokuapp.com")!

//GraphQLSchema.downloadFrom(endpoint) { (schema: GraphQL.Schema) in
//    print(schema.objects)
//}


GraphQLCodegen.generate(from: endpoint) { code in
    print(code)
}
