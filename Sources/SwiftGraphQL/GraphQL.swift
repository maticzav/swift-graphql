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

/// Global type used to select query fields.
public class SelectionSet<Type, TypeLock> {
    private(set) var fields = [GraphQLField]() // selected fields
    private var data: Any? // response data
    
    init() {}
    
    init(data: Any) {
        /* This initializer is used to decode response into Swift data. */
        self.data = data
    }
    
    // MARK: - Accessors
    
    /// Lets generated code read the data.
    ///
    /// - Note: This function should only be used by the generated code.
    public var response: Any? {
        data
    }
    
    // MARK: - Methods
    
    /// Lets generated code add a selection to the selection set.
    ///
    /// - Note: This function should only be used by the generated code.
    public func select(_ field: GraphQLField) {
        self.fields.append(field)
    }
}

/// Global type used to wrap the selection.
public struct Selection<Type, TypeLock> {
    public typealias SelectionDecoder = (SelectionSet<Type, TypeLock>) -> Type
    
    /* Data */

    private let selectionSet = SelectionSet<Type, TypeLock>()
    private var decoder: SelectionDecoder // function used to decode data and populate selection
    private var mocked: Type // mock data
    
    
    // MARK: - Initializer
    
    public init(decoder: @escaping SelectionDecoder) {
        /* This initializer populates fields (selection set) and grabs a copy of mocked value. */
        self.decoder = decoder
        self.mocked = decoder(selectionSet)
    }
    
    // MARK: - Accessors
    
    /// Returns a list of selected fields.
    public var selection: [GraphQLField] {
        self.selectionSet.fields
    }
    
    // MARK: - Methods
    
    /// Decodes JSON response into a return type of the selection set.
    ///
    /// - Note: Don't use this function. This function should only be used internally by SwiftGraphQL.
    public func decode(data: Any) -> Type {
        /* Construct a copy of the selection set, and use the new selection set to decode data. */
        let data = (data as! [String: Any?])
        let selectionSet = SelectionSet<Type, TypeLock>(data: data)
        return self.decoder(selectionSet)
    }
    
    /// Mocks the data of a selection.
    ///
    /// - Note: Don't use this function. This function should only be used internally by SwiftGraphQL.
    public func mock() -> Type {
        self.mocked
    }
    
    /// Returns a GraphQL query for the current selection set.
    func serialize(for operationType: GraphQLOperationType) -> String {
        """
        \(operationType.rawValue) {
        \(selection.map { serializeSelection($0, level: 1) }.joined(separator: "\n"))
        }
        """
    }
    
    private func serializeSelection(_ selection: GraphQLField, level indentation: Int) -> String {
        switch selection {
        case .leaf(let field):
            return "\(generateIndentation(level: indentation))\(field.name)"
        case .composite(let name, let selection):
            return """
            \(generateIndentation(level: indentation))\(name) {
            \(selection.map { serializeSelection($0, level: indentation + 1) }.joined(separator: "\n"))
            \(generateIndentation(level: indentation))}
            """
        }
    }
    
    private func generateIndentation(level: Int) -> String {
        String(repeating: " ", count: level * 2)
    }
}

extension Selection {
    /// Lets you convert a type selection into a list selection.
    public var list: Selection<[Type], [TypeLock]> {
        return Selection<[Type], [TypeLock]> { selection in
            self.selection.forEach(selection.select)
            
            if let data = selection.response {
                return (data as! [Any]).map { self.decode(data: $0) }
            }
            
            return []
        }
    }

    /// Lets you decode nullable values.
    public var nullable: Selection<Type?, TypeLock?> {
        Selection<Type?, TypeLock?> { selection in
            self.selection.forEach(selection.select)
            
            if let data = selection.response {
                return self.decode(data: data)
            }
            
            return nil
        }
    }
}


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
    public static func send<Type>(selection: Selection<Type, RootQuery>, completionHandler: @escaping (GraphQLResult<Type>) -> Void) -> Void {
        perform(selection: selection, completionHandler: completionHandler)
    }
    
    /// Sends a mutation request to the server.
    public static func send<Type>(selection: Selection<Type, RootMutation>, completionHandler: @escaping (GraphQLResult<Type>) -> Void) -> Void {
        perform(selection: selection, completionHandler: completionHandler)
    }
    
    /// Sends a subscription request to the server.
    public static func send<Type>(selection: Selection<Type, RootSubscription>, completionHandler: @escaping (GraphQLResult<Type>) -> Void) -> Void {
        perform(selection: selection, completionHandler: completionHandler)
    }
    
    /// Returns a query for selection.
    public static func serialize<Type, TypeLock>(selection: Selection<Type, TypeLock>) -> String {
        selection.serialize(for: .query)
    }
    
    /* Internals */
    
    private static func perform<Type, TypeLock>(
        selection: Selection<Type, TypeLock>,
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
        with selection: Selection<Type, TypeLock>
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

