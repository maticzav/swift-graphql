import Foundation


// MARK: - GraphQLField

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
    

// MARK: - SelectionSet

public typealias JSONData = [String: Any?]

enum GraphQLOperationType: String, CaseIterable {
    case query = "query"
    case mutation = "mutation"
    case subscription = "subscription"
}

public class SelectionSet<Type, TypeLock> {
    /* Data */
    
    private var fields = [GraphQLField]() // selected fields
    private var decoder: (SelectionSet) -> Type // function used to decode data and populate selection
    private var mocked: Type? // mock data
    private var _data: JSONData? // return object
    
    // MARK: - Initializer
    
    public init(decoder: @escaping (SelectionSet) -> Type) {
        /* This initializer populates fields (selection set) and grabs a copy of mocked value. */
        self.decoder = decoder
        self.mocked = self.decoder(self)
    }
    
    private init(decoder: @escaping (SelectionSet) -> Type, data: JSONData) {
        /* This initializer is used to decode response into Swift data. */
        self.decoder = decoder
        self._data = data
    }
    
    // MARK: - Accessors
    
    public var data: JSONData? {
        return self._data
    }
    
    /// Returns a list of selected fields.
    public var selection: [GraphQLField] {
        return self.fields
    }
    
    /// Lets API add a selection to the selection set.
    public func select(_ field: GraphQLField) {
        self.fields.append(field)
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
    
    /// Returns a GraphQL query for the current selection set.
    func serialize(for operationType: GraphQLOperationType) -> String {
        """
        \(operationType.rawValue) {
        \(fields.map(serializeSelection).joined(separator: "\n"))
        }
        """
    }
    
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
//
//extension SelectionSet {
//    /// Let's you convert a type selection into a list selection.
//    func list() -> SelectionSet<[Type], [TypeLock]> {
//        SelectionSet<[Type], [TypeLock]> { selection in
//            if let data = self.data {
//                return (data as! [Any]).map(self.decoder)
//            }
//            
//            return []
//        }
//    }
//    
//    func nullable() -> SelectionSet<Type?, TypeLock?> {
//        SelectionSet<Type?, TypeLock?> { selection in
//            if let data = self.data {
//                return (data as! Any?).map(self.decoder)
//            }
//        }
//    }
//}


// MARK: - GraphQLError


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


// MARK: - Operations

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

// MARK: - Methods

struct GraphQLResponse {
    let data: JSONData?
    let errors: [GraphQLError]
}

public typealias GraphQLResult<T> = Result<T?, RequestError>

public struct GraphQLClient {
    static let endpoint = URL(string: "http://localhost:5000")!
    
    /* API */
    
    /// Sends a query request to the server.
    public static func send<Type>(selection: SelectionSet<Type, RootQuery>, completionHandler: @escaping (GraphQLResult<Type>) -> Void) -> Void {
        perform(selection: selection, completionHandler: completionHandler)
    }
    
    /// Sends a mutation request to the server.
    public static func send<Type>(selection: SelectionSet<Type, RootMutation>, completionHandler: @escaping (GraphQLResult<Type>) -> Void) -> Void {
        perform(selection: selection, completionHandler: completionHandler)
    }
    
    /// Sends a subscription request to the server.
    public static func send<Type>(selection: SelectionSet<Type, RootSubscription>, completionHandler: @escaping (GraphQLResult<Type>) -> Void) -> Void {
        perform(selection: selection, completionHandler: completionHandler)
    }
    
    /* Internals */
    
    private static func perform<Type, TypeLock>(
        selection: SelectionSet<Type, TypeLock>,
        completionHandler: @escaping (GraphQLResult<Type>
    ) -> Void) -> Void {
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

