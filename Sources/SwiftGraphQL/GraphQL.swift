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

public enum GraphQLField {
    /// Represents an object selection.
    case composite(String, [GraphQLField])
    /// Represents a scalar selection.
    case leaf(Field)
    
    // MARK: - Constructors
    
    /// A shorthand for creating a leaf.
    static public func leaf(name: String) -> GraphQLField {
        .leaf(Field(name: name))
    }
    
    static public func composite(name: String, selection: [GraphQLField]) -> GraphQLField {
        .composite(name, selection)
    }
    
    // MARK: - Calculated properties
    
    public var name: String {
        switch self {
        case .composite(let name, _):
            return name
        case .leaf(let field):
            return field.name
        }
    }
    
    // MARK: - Field
    
    public struct Field {
        var name: String
    }
}
    

// MARK: - SelectionSet (https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/SelectionSet.elm)

public typealias JSONData = [String: Any?]

enum GraphQLOperationType: String, CaseIterable {
    case query = "query"
    case mutation = "mutation"
    case subscription = "subscription"
}

public struct SelectionSet<Type, TypeLock> {
    //    https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/SelectionSet.elm
    private var fields = [GraphQLField]()
    private let decoder: (Self) -> Type
    private var mocked: Type?
    
    public var data: JSONData? // return object
    
    // MARK: - Initializer
    
    public init(decoder: @escaping (Self) -> Type) {
        self.decoder = decoder
        self.mocked = self.decoder(self)
    }
    
    private init(decoder: @escaping (Self) -> Type, data: JSONData) {
        self.decoder = decoder
        self.data = data
    }
    
    // MARK: - Methods
    
    /// Decodes JSON response into a return type of the selection set.
    public func decode(data: Any) -> Type {
        /* Construct a copy of the selection set, and use the new selection set to decode data. */
        let data = (data as! [String: Any?])
        let selection = SelectionSet(decoder: self.decoder, data: data)
        
        return self.decoder(selection)
    }
    
    /// Mocks the data of a selection.
    public func mock() -> Type {
        return self.mocked!
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


public struct GraphQLError: Error, Codable {
    let message: String
    let location: [Location]?
    
    struct Location: Codable {
        let line: Int
        let column: Int
    }
}


public enum RequestError: Error {
    case graphql([GraphQLError])
    case http(Error?)
}


// MARK: - Methods (https://github.com/dillonkearns/elm-graphql/blob/master/src/Graphql/Http.elm send and toReadyRequest methods)

struct GraphQLResponse {
    let data: JSONData?
    let errors: [GraphQLError]
}

public typealias GraphQLResult<T> = Result<T?, RequestError>

public struct GraphQLClient {
    static let endpoint = URL(string: "http://localhost:5000")!
    
    /// Sends a query request to the server.
    static func send<T>(selection: SelectionSet<T, RootQuery>, completionHandler: @escaping (GraphQLResult<T>) -> Void) -> Void {
        /* Compose a request. */
        var request = URLRequest(url: endpoint)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let query: [String: Any] = [
            "query": selection.serialize(for: .query)
        ]
        
        request.httpBody = try! JSONSerialization.data(
            withJSONObject: query,
            options: JSONSerialization.WritingOptions()
        )
        
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
    
    /// Parses the data with given selection.
    private static func parse<Type, TypeLock>(
        _ response: GraphQLResponse,
        with selection: SelectionSet<Type, TypeLock>
    ) -> GraphQLResult<Type> {
        if response.errors.isEmpty {
            /* Return the data. */
            return .success(response.data.map { selection.decode(data: $0) })
        } else {
            /* Return the error set. */
            return .failure(.graphql(response.errors))
        }
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
