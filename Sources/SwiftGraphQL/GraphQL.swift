import Foundation




//decoder : SelectionSet decodesTo typeLock -> Decoder decodesTo
//decoder (SelectionSet fields decoder_) =
//    decoder_ |> Decode.field "data"


/* Library */


// MARK: - Operations (https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/Operation.elm)

/*
    Contains types used to annotate top-level queries which can be
    built up using generated functions.
*/

public enum Operation {
    public enum Query {}
    public enum Mutation {}
    public enum Subscription {}
}

public typealias RootQuery = Operation.Query
public typealias RootMutation = Operation.Mutation
public typealias RootSubscription = Operation.Subscription





// MARK: - GraphQLField (https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/RawField.elm, https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/Document/Field.elm)

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


enum GraphQLOperationType: String, CaseIterable {
    case query = "query"
    case mutation = "mutation"
    case subscription = "subscription"
}

typealias JSONData = [String: Any?]

struct GraphQLResponse {
    let data: JSONData?
    let errors: [GraphQLError]
}



// MARK: - GraphQLError (https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/Http/GraphqlError.elm)


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
            let response = parse(GraphQLResponse(data: data, errors: errors), with: selection)
            
            return completionHandler(response)
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

// MARK: - Internals (https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/Internal/Builder/Object.elm)


enum GraphQLScalarType: CaseIterable {
    case int
    case float
    case string
    case boolean
    case id
}
