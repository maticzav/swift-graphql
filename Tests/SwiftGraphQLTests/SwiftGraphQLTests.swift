import XCTest
@testable import SwiftGraphQL

final class SwiftGraphQLTests: XCTestCase {
    func test() {
        struct User {
            var id: String
            var name: String
            var picture: String?
            /* Relations */
            var pet: String?
        }



        struct Pet {
            var id: String
            var name: String
        }




        // This should return a more complex type and resolve it in helper functions.
        let user = SelectionSet<User, UserObject> {
           User(
                id: $0.id(),
                name: $0.name(),
                picture: $0.picture(),
                vehicle: $0.vehicle(),
                pet: $0.pet(pet)
           )
        }

        let pet = SelectionSet<String, PetObject> { selection in
            "My dog \(selection.name())!"
        }



        let query = SelectionSet<[User], RootQuery> { $0.users(user) }

        /* Mock query */


        let data: Data = """
        {
          "data": {
            "users": [
              {
                "id": "1",
                "name": "Matic",
                "picture": null,
                "age": 20,
                "vehicle": "BIKE",
                "pet": null
              },
              {
                "id": "2",
                "name": "Manca",
                "picture": null,
                "age": 20,
                "vehicle": "CAR",
                "pet": null
              },
              {
                "id": "3",
                "name": "Tela",
                "picture": null,
                "age": 20,
                "vehicle": "BUS",
                "pet": {
                  "id": "4",
                  "name": "Kala"
                }
              }
            ]
          },
          "errors": []
        }
        """.data(using: .utf8)!

        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! JSONData
        let response = GraphQLResponse(
            data:  (json["data"] as! JSONData),
            errors: json["errors"] as! [GraphQLError]
        )
         

        let res = parse(response, with: query)
        print(res)

    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
