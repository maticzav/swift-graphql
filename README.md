# swift-graphql :construction:



/*
 1. Let's use Swift's "Result" type to handle responses.
 2. Use argument hashing to generate unique keys in queries.
 */


https://sampleapis.com


## Guiding principles

* Use high-level Swift language features instead of a complicated library.
* Any query you can create is valid.
 
 What this library does:
 - it lets you build queries programatically,
 - it lets you send queries through Swift's Network protocol and receive results.
 
 What this library does not do:
 - it has no caching layer

## Introduction

```gql
type Query {
  # Currently logged in user
  viewer: User
  # lets you search users.
  users(name: String?): [User!]!
}

type User {
  id: ID
  name: String
  picture: String?

  friends: [User]
}
```


```swift

struct User {
  var id: String
  var name: String
  var picture: String?
}

let client = GQL.createClient(
  url: "https://localhost:3000",
  fetchOptions: { _ in
    let token = getToken()
    return {
      "headers": { "Authorization": "Bearer \(token)" }
    }
  }
)

let user = GQL.selection 
  // mapping function
  { data in 
    User(
      id: data.id,
      name: data.name,
      picture: data.picture
    )
  }
  // selection
  .with(GQL.User.id)
  .with(GQL.User.name)
  .with(GQL.User.picture)
  // .with(GQL.User.friends GQL.list(user))

let query = GQL.query { identity($0) } .with(user)

struct UserView: View {
  @Query(query) var user: GQL.Response<User>

  var body: some View {
    Text("Hi \(user.name)!")
  }
}

```


## Generating Swift code

```swift
import SwiftGraphQLCodegen

let endpoint = URL(string: "http://localhost:5000/")!
let schema = Path.file("")
let target = Path.file("")

let options = GraphQLCodegenOptions(
    namespace: "API"
)

do {
    try GraphQLSchema.downloadFrom(endpoint, to: schema)
    try GraphQLCodegen.generate(target, from: schema)
} catch {
    exit(1)
}
```


### What would we need?

- [ ] client
- [ ] .selection
- [ ] .query

**Code generation**:

* Separate files for Query(ies) and Mutation(s) with all available queries
* API generated file with all objects and their selections



```swift

import Foundation

/*
 Guiding principles:
 - you can use high-level Swift language features instead of a complicated library,
 - any query you create is valid
 
 
 What this library does:
 - it lets you build queries programatically,
 - it lets you send queries through Swift's Network protocol and receive results.
 
 What this library does not do:
 - it has no caching layer
 
 */


/*
 1. Let's use Swift's "Result" type to handle responses.
 2. Use argument hashing to generate unique keys in queries.
 */

//decoder : SelectionSet decodesTo typeLock -> Decoder decodesTo
//decoder (SelectionSet fields decoder_) =
//    decoder_ |> Decode.field "data"


/* Library */


// MARK: - Operations (https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/Operation.elm)

/*
    Contains types used to annotate top-level queries which can be
    built up using generated functions.
*/

enum Operation {
    enum Query {}
    enum Mutation {}
    enum Subscription {}
}

typealias RootQuery = Operation.Query
typealias RootMutation = Operation.Mutation
typealias RootSubscription = Operation.Subscription


// MARK: - GraphQLField (https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/RawField.elm, https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/Document/Field.elm)

//type RawField
//    = Composite String (List Argument) (List RawField)
//    | Leaf { typeString : String, fieldName : String } (List Argument)

// TODO: Arguments

enum GraphQLField {
    /// Represents an object selection.
    case composite(String, [GraphQLField])
    /// Represents a scalar selection.
    case leaf(Field)
    
    // MARK: - Constructors
    
    /// A shorthand for creating a leaf.
    static func leaf(name: String) -> GraphQLField {
        .leaf(Field(name: name))
    }
    
    static func composite(name: String, selection: [GraphQLField]) -> GraphQLField {
        .composite(name, selection)
    }
    
    // MARK: - Calculated properties
    
    var name: String {
        switch self {
        case .composite(let name, _):
            return name
        case .leaf(let field):
            return field.name
        }
    }
    
    // MARK: - Field
    
    struct Field {
        var name: String
    }
}
    

// MARK: - SelectionSet (https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/SelectionSet.elm)

//        type SelectionSet decodesTo typeLock
//            = SelectionSet (List RawField) (Decoder decodesTo)


enum GraphQLOperationType: String, CaseIterable {
    case query = "query"
    case mutation = "mutation"
    case subscription = "subscription"
}

typealias JSONData = [String: Any?]

struct SelectionSet<Type, TypeLock> {
    //    https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/SelectionSet.elm
    private var fields = [GraphQLField]()
    private let decoder: (Self) -> Type
    
    private var data: JSONData? // return object
    
    // MARK: - Initializer
    
    init(decoder: @escaping (Self) -> Type) {
        self.decoder = decoder
        self.decoder(self)
    }
    
    private init(decoder: @escaping (Self) -> Type, data: JSONData) {
        self.decoder = decoder
        self.data = data
    }
    
    // MARK: - Methods
    
    /// Decodes JSON response into a return type of the selection set.
    func decode(data: Any) -> Type {
        /* Construct a copy of the selection set, and use the new selection set to decode data. */
        let data = (data as! [String: Any?])
        let selection = SelectionSet(decoder: self.decoder, data: data)
        
        return self.decoder(selection)
    }
    
    // https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/Document.elm
    
    /// Returns a GraphQL query for the current selection set.
    func serialize(for operationType: GraphQLOperationType) -> String {
        """
        \(operationType.rawValue) {
        \(fields.map(serializeSelection).joined(separator: "\n"))
        }
        """
    }
    
    /* Helper functions */
    
    private func serializeSelection(_ selection: GraphQLField) -> String {
        switch selection {
        case .leaf(let field):
            return "\(field.name)"
        case .composite(let name, let selection):
            return """
            \(name) {
            \(selection.map(serializeSelection).joined(separator: "\n"))
            }
            """
        }
    }
}

// MARK: - GraphQLError (https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/Http/GraphqlError.elm)

struct GraphQLResponse {
    let data: JSONData?
    let errors: [GraphQLError]
}

struct GraphQLError: Error, Codable {
    let message: String
    let location: [Location]?
    
    struct Location: Codable {
        let line: Int
        let column: Int
    }
}


enum RequestError: Error {
    case graphql([GraphQLError])
    case http(Error?)
}




// MARK: - Methods (https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/Http.elm send and toReadyRequest methods)

typealias GraphQLResult<T> = Result<T?, RequestError>

func send<T>(selection: SelectionSet<T, RootQuery>, completionHandler: @escaping (GraphQLResult<T>) -> Void) -> Void {
    /* Serialize a query. */
    let query = selection.serialize(for: .query)
    
    /* Compose a request. */
    let url = URL(string: "http://localhost:5000")!
    var request = URLRequest(url: url)
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = query.data(using: .utf8)
    
    /* Parse the data and return the result. */
    func onComplete(data: Data?, response: URLResponse?, error: Error?) -> Void {
        /* Check for errors. */
        if let error = error {
            return completionHandler(.failure(.http(error)))
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
            return completionHandler(.failure(.http(nil)))
        }
        
        /* Serialize received JSON. */
        if let data = data,
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONData {
            let data = json["data"] as? JSONData
            let errors = json["errors"] as? [GraphQLError] ?? []
            
            /* Process the GraphQL repsonse. */
            parse(GraphQLResponse(data: data, errors: errors), with: selection)
        }
    }
    
    /* Kick off the request. */
    URLSession.shared.dataTask(with: request, completionHandler: onComplete).resume()
}


func parse<Type, TypeLock>(_ response: GraphQLResponse, with selection: SelectionSet<Type, TypeLock>) -> GraphQLResult<Type> {
    if response.errors.isEmpty {
        /* Return the data. */
        return .success(response.data.map { selection.decode(data: $0) })
    } else {
        /* Return the error set. */
        return .failure(.graphql(response.errors))
    }
}

//
//func send<T>(selection: SelectionSet<T, RootMutation>) -> T {
//
//}
//
//
//func send<T>(selection: SelectionSet<T, RootSubscription>) -> T {
//
//}







// MARK: - Internals (https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/Internal/Builder/Object.elm)


enum GraphQLScalarType: CaseIterable {
    case int
    case float
    case string
    case boolean
    case id
}






/*
    type Query {
        users: [User!]!
    }
 
    type User {
        id: ID!
        name: String!
        picture: String
        age: Int

        vehicle: Vehicle
        pet: Pet
    }
 
    type Pet {
        id: ID!
        name: String!
        type: PetType
    }
     
 
     enum Vehicle {
         CAR
         BIKE
         BUS
     }
 
    enum PetType {
        CAT
        DOG
        OTHER
    }
 */


// MARK: - Generated

/*
 1. In general it is always so that you should create phantom types for every object, union... - generally anything
     that has some form of a selection set - and extend the selection set afterwards.
 2. The return type of every selector is a generic "Type". We modify the return type in case it is nullable or list.
 */



// Operations

extension SelectionSet where TypeLock == RootQuery {
    func users<Type>(_ selection: SelectionSet<Type, UserObject>) -> [Type] {
        let field = GraphQLField.leaf(name: "users")
        
        if let data = self.data {
            return (data[field.name] as! [Any]).map { selection.decode(data: $0) }
        }
        
        return []
    }
}




// Objects (might be good to extract to a separate file to prevent circular imports)

enum Object {
    enum User {}
    enum Pet {}
}

typealias UserObject = Object.User
typealias PetObject = Object.Pet


// Enums (might be a separate file or folder
// most of what elm-graphql is doing by hand Swift has prebuilt
// (decoding from string, encoding to string, all cases)


enum Vehicle: String, CaseIterable {
    case car = "CAR"
    case bike = "BIKE"
    case bus = "BUS"
}

enum PetType: String, CaseIterable {
    case cat = "CAT"
    case dog = "DOG"
    case other = "OTHER"
}


// SeleectionSet

extension SelectionSet where TypeLock == UserObject {
    /* Fields */
    
    /// Description of the funciton taken from the GraphQL docs.
    func id() -> String {
        let field = GraphQLField.leaf(name: "id")
        
        if let data = self.data {
            return data[field.name] as! String
        }
        
        return "String"
    }
    
    /// Description of the funciton taken from the GraphQL docs.
    func name() -> String {
        let field = GraphQLField.leaf(name: "name")
        
        if let data = self.data {
            return data[field.name] as! String
        }
        
        return "String"
    }
    
    /// Description of the funciton taken from the GraphQL docs.
    func picture() -> String? {
        let field = GraphQLField.leaf(name: "picture")
        
        if let data = self.data {
            return data[field.name] as! String?
        }
        
        return nil
    }
    
    
    /// Description of the funciton taken from the GraphQL docs.
    func age() -> Int {
        let field = GraphQLField.leaf(name: "age")
        
        if let data = self.data {
            return data[field.name] as! Int
        }
        
        return 42
    }
    
    /// Description of the funciton taken from the GraphQL docs.
    func vehicle() -> Vehicle {
        let field = GraphQLField.leaf(name: "vehicle")
        
        if let data = self.data {
            return Vehicle.init(rawValue: data[field.name] as! String)!
        }
        
        return Vehicle.allCases.first!
    }
    
    /// Description of the funciton taken from the GraphQL docs.
    func pet<Type>(_ selection: SelectionSet<Type, PetObject>) -> Type? {
        let field = GraphQLField.leaf(name: "pet")
        
        if let data = self.data {
            return (data[field.name] as! Any?).map { selection.decode(data: $0) }
        }
        
        return nil
    }
}



extension SelectionSet where TypeLock == PetObject {
    // non-nullable scalar
    func id() -> String {
        let field = GraphQLField.leaf(name: "id")
        
        if let data = self.data {
            return data[field.name] as! String
        }
        
        return "String"
    }
    
    // nullable scalar
    func name() -> String {
        let field = GraphQLField.leaf(name: "name")
        
        if let data = self.data {
            return data[field.name] as! String
        }
        
        return "String"
    }
    
    /// GraphQL provided description.
    func type() -> PetType? {
        let field = GraphQLField.leaf(name: "type")
        
        if let data = self.data {
            return (data[field.name] as! String?).map { PetType.init(rawValue:  $0)! }
        }
        
        return nil
    }
}







/* Usage. */




struct User {
    var id: String
    var name: String
    var picture: String?
    /* Relations */
    var vehicle: Vehicle?
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


```
