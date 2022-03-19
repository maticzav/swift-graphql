// This file was auto-generated using maticzav/swift-graphql. DO NOT EDIT MANUALLY!
import Foundation
import SwiftGraphQL

// MARK: - Operations
enum Operations {}
extension Objects.Query: GraphQLHttpOperation {
    public static var operation: GraphQLOperationKind { .query }
}
extension Objects.Mutation: GraphQLHttpOperation {
    public static var operation: GraphQLOperationKind { .mutation }
}
extension Objects.Subscription: GraphQLWebSocketOperation {
    public static var operation: GraphQLOperationKind { .subscription }
}

// MARK: - Objects
enum Objects {}
extension Objects {
struct User {
    let __typename: TypeName = .user
    let id: [String: String]
let username: [String: String]

    enum TypeName: String, Codable {
case user = "User"
}
}
}

extension Objects.User: Decodable {
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
        case "id":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "username":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown key \(field)."
                )
            )
        }
    }

    

    self.id = map["id"]
self.username = map["username"]
}
}

extension Fields where TypeLock == Objects.User {


func id() throws -> String {
    let field = GraphQLField.leaf(
     field: "id",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.id[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}
/// A nickname user has picked for themself.

func username() throws -> String {
    let field = GraphQLField.leaf(
     field: "username",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.username[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}
}
extension Selection where TypeLock == Never, Type == Never {
    typealias User<T> = Selection<T, Objects.User>
}
extension Objects {
struct Query {
    let __typename: TypeName = .query
    let characters: [String: [Objects.Character]]
let comics: [String: [Objects.Comic]]
let hello: [String: String]
let search: [String: [Unions.SearchResult]]
let user: [String: Objects.User]

    enum TypeName: String, Codable {
case query = "Query"
}
}
}

extension Objects.Query: Decodable {
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
        case "characters":
    if let value = try container.decode([Objects.Character]?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "comics":
    if let value = try container.decode([Objects.Comic]?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "hello":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "search":
    if let value = try container.decode([Unions.SearchResult]?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "user":
    if let value = try container.decode(Objects.User?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown key \(field)."
                )
            )
        }
    }

    

    self.characters = map["characters"]
self.comics = map["comics"]
self.hello = map["hello"]
self.search = map["search"]
self.user = map["user"]
}
}

extension Fields where TypeLock == Objects.Query {
/// Simple field that always returns "Hello world!".

func hello() throws -> String {
    let field = GraphQLField.leaf(
     field: "hello",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.hello[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}
/// Returns currently authenticated user and errors if there's no authenticated user.

func user<T>(selection: Selection<T, Objects.User>) throws -> T {
    let field = GraphQLField.composite(
     field: "user",
     type: "User",
     arguments: [  ],
     selection: selection.selection()
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.user[field.alias!] {
    return try selection.decode(data: data)
}
throw SelectionError.badpayload
    case .mocking:
        return try selection.mock()
    }
}
/// Returns a list of comics from the Marvel universe.

func comics<T>(pagination: OptionalArgument<InputObjects.Pagination> = .absent(), selection: Selection<T, [Objects.Comic]>) throws -> T {
    let field = GraphQLField.composite(
     field: "comics",
     type: "Comic",
     arguments: [ Argument(name: "pagination", type: "Pagination", value: pagination) ],
     selection: selection.selection()
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.comics[field.alias!] {
    return try selection.decode(data: data)
}
throw SelectionError.badpayload
    case .mocking:
        return try selection.mock()
    }
}
/// Returns a list of characters from the Marvel universe.

func characters<T>(pagination: OptionalArgument<InputObjects.Pagination> = .absent(), selection: Selection<T, [Objects.Character]>) throws -> T {
    let field = GraphQLField.composite(
     field: "characters",
     type: "Character",
     arguments: [ Argument(name: "pagination", type: "Pagination", value: pagination) ],
     selection: selection.selection()
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.characters[field.alias!] {
    return try selection.decode(data: data)
}
throw SelectionError.badpayload
    case .mocking:
        return try selection.mock()
    }
}
/// Searches all characters and comics by name and returns those whose
/// name starts with the query string.

func search<T>(query: InputObjects.Search , pagination: OptionalArgument<InputObjects.Pagination> = .absent(), selection: Selection<T, [Unions.SearchResult]>) throws -> T {
    let field = GraphQLField.composite(
     field: "search",
     type: "SearchResult",
     arguments: [ Argument(name: "query", type: "Search!", value: query),Argument(name: "pagination", type: "Pagination", value: pagination) ],
     selection: selection.selection()
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.search[field.alias!] {
    return try selection.decode(data: data)
}
throw SelectionError.badpayload
    case .mocking:
        return try selection.mock()
    }
}
}
extension Selection where TypeLock == Never, Type == Never {
    typealias Query<T> = Selection<T, Objects.Query>
}
extension Objects {
struct Character {
    let __typename: TypeName = .character
    let description: [String: String]
let id: [String: String]
let image: [String: String]
let name: [String: String]
let starred: [String: Bool]

    enum TypeName: String, Codable {
case character = "Character"
}
}
}

extension Objects.Character: Decodable {
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
        case "description":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "id":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "image":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "name":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "starred":
    if let value = try container.decode(Bool?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown key \(field)."
                )
            )
        }
    }

    

    self.description = map["description"]
self.id = map["id"]
self.image = map["image"]
self.name = map["name"]
self.starred = map["starred"]
}
}

extension Fields where TypeLock == Objects.Character {


func id() throws -> String {
    let field = GraphQLField.leaf(
     field: "id",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.id[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}


func name() throws -> String {
    let field = GraphQLField.leaf(
     field: "name",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.name[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}


func description() throws -> String {
    let field = GraphQLField.leaf(
     field: "description",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.description[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}
/// URL of the character image.

func image() throws -> String {
    let field = GraphQLField.leaf(
     field: "image",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.image[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}
/// Tells whether currently authenticated user has starred this character.
/// NOTE: If there's no authenticated user, this field will always return false.

func starred() throws -> Bool {
    let field = GraphQLField.leaf(
     field: "starred",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.starred[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return Bool.mockValue
    }
}
}
extension Selection where TypeLock == Never, Type == Never {
    typealias Character<T> = Selection<T, Objects.Character>
}
extension Objects {
struct Comic {
    let __typename: TypeName = .comic
    let description: [String: String]
let id: [String: String]
let isbn: [String: String]
let pageCount: [String: Int]
let starred: [String: Bool]
let thumbnail: [String: String]
let title: [String: String]

    enum TypeName: String, Codable {
case comic = "Comic"
}
}
}

extension Objects.Comic: Decodable {
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
        case "description":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "id":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "isbn":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "pageCount":
    if let value = try container.decode(Int?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "starred":
    if let value = try container.decode(Bool?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "thumbnail":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "title":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown key \(field)."
                )
            )
        }
    }

    

    self.description = map["description"]
self.id = map["id"]
self.isbn = map["isbn"]
self.pageCount = map["pageCount"]
self.starred = map["starred"]
self.thumbnail = map["thumbnail"]
self.title = map["title"]
}
}

extension Fields where TypeLock == Objects.Comic {


func id() throws -> String {
    let field = GraphQLField.leaf(
     field: "id",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.id[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}


func title() throws -> String {
    let field = GraphQLField.leaf(
     field: "title",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.title[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}


func description() throws -> String {
    let field = GraphQLField.leaf(
     field: "description",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.description[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}


func isbn() throws -> String {
    let field = GraphQLField.leaf(
     field: "isbn",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.isbn[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}
/// URL of the thumbnail image.

func thumbnail() throws -> String {
    let field = GraphQLField.leaf(
     field: "thumbnail",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.thumbnail[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}


func pageCount() throws -> Int? {
    let field = GraphQLField.leaf(
     field: "pageCount",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        return data.pageCount[field.alias!]
    case .mocking:
        return nil
    }
}
/// Tells whether currently authenticated user has starred this comic.

func starred() throws -> Bool {
    let field = GraphQLField.leaf(
     field: "starred",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.starred[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return Bool.mockValue
    }
}
}
extension Selection where TypeLock == Never, Type == Never {
    typealias Comic<T> = Selection<T, Objects.Comic>
}
extension Objects {
struct Mutation {
    let __typename: TypeName = .mutation
    let auth: [String: Unions.AuthPayload]
let star: [String: Unions.SearchResult]
let uploadFile: [String: Objects.File]

    enum TypeName: String, Codable {
case mutation = "Mutation"
}
}
}

extension Objects.Mutation: Decodable {
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
        case "auth":
    if let value = try container.decode(Unions.AuthPayload?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "star":
    if let value = try container.decode(Unions.SearchResult?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "uploadFile":
    if let value = try container.decode(Objects.File?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown key \(field)."
                )
            )
        }
    }

    

    self.auth = map["auth"]
self.star = map["star"]
self.uploadFile = map["uploadFile"]
}
}

extension Fields where TypeLock == Objects.Mutation {
/// Creates a random authentication session.

func auth<T>(selection: Selection<T, Unions.AuthPayload>) throws -> T {
    let field = GraphQLField.composite(
     field: "auth",
     type: "AuthPayload",
     arguments: [  ],
     selection: selection.selection()
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.auth[field.alias!] {
    return try selection.decode(data: data)
}
throw SelectionError.badpayload
    case .mocking:
        return try selection.mock()
    }
}
/// Adds a star to a comic or a character.

func star<T>(id: String , item: Enums.Item , selection: Selection<T, Unions.SearchResult>) throws -> T {
    let field = GraphQLField.composite(
     field: "star",
     type: "SearchResult",
     arguments: [ Argument(name: "id", type: "ID!", value: id),Argument(name: "item", type: "Item!", value: item) ],
     selection: selection.selection()
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.star[field.alias!] {
    return try selection.decode(data: data)
}
throw SelectionError.badpayload
    case .mocking:
        return try selection.mock()
    }
}
/// Creates a new upload URL for a file and returns an ID.
/// NOTE: The file should be uploaded to the returned URL. If the user is not
/// authenticated, mutation will throw an error.

func uploadFile<T>(contentType: String , `extension`: OptionalArgument<String> = .absent(), folder: String , selection: Selection<T, Objects.File>) throws -> T {
    let field = GraphQLField.composite(
     field: "uploadFile",
     type: "File",
     arguments: [ Argument(name: "contentType", type: "String!", value: contentType),Argument(name: "extension", type: "String", value: `extension`),Argument(name: "folder", type: "String!", value: folder) ],
     selection: selection.selection()
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.uploadFile[field.alias!] {
    return try selection.decode(data: data)
}
throw SelectionError.badpayload
    case .mocking:
        return try selection.mock()
    }
}
}
extension Selection where TypeLock == Never, Type == Never {
    typealias Mutation<T> = Selection<T, Objects.Mutation>
}
extension Objects {
struct AuthPayloadSuccess {
    let __typename: TypeName = .authPayloadSuccess
    let token: [String: String]
let user: [String: Objects.User]

    enum TypeName: String, Codable {
case authPayloadSuccess = "AuthPayloadSuccess"
}
}
}

extension Objects.AuthPayloadSuccess: Decodable {
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
        case "token":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "user":
    if let value = try container.decode(Objects.User?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown key \(field)."
                )
            )
        }
    }

    

    self.token = map["token"]
self.user = map["user"]
}
}

extension Fields where TypeLock == Objects.AuthPayloadSuccess {


func token() throws -> String {
    let field = GraphQLField.leaf(
     field: "token",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.token[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}


func user<T>(selection: Selection<T, Objects.User>) throws -> T {
    let field = GraphQLField.composite(
     field: "user",
     type: "User",
     arguments: [  ],
     selection: selection.selection()
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.user[field.alias!] {
    return try selection.decode(data: data)
}
throw SelectionError.badpayload
    case .mocking:
        return try selection.mock()
    }
}
}
extension Selection where TypeLock == Never, Type == Never {
    typealias AuthPayloadSuccess<T> = Selection<T, Objects.AuthPayloadSuccess>
}
extension Objects {
struct AuthPayloadFailure {
    let __typename: TypeName = .authPayloadFailure
    let message: [String: String]

    enum TypeName: String, Codable {
case authPayloadFailure = "AuthPayloadFailure"
}
}
}

extension Objects.AuthPayloadFailure: Decodable {
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
        case "message":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown key \(field)."
                )
            )
        }
    }

    

    self.message = map["message"]
}
}

extension Fields where TypeLock == Objects.AuthPayloadFailure {


func message() throws -> String {
    let field = GraphQLField.leaf(
     field: "message",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.message[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}
}
extension Selection where TypeLock == Never, Type == Never {
    typealias AuthPayloadFailure<T> = Selection<T, Objects.AuthPayloadFailure>
}
extension Objects {
struct File {
    let __typename: TypeName = .file
    let id: [String: String]
let publicUrl: [String: String]
let uploadUrl: [String: String]

    enum TypeName: String, Codable {
case file = "File"
}
}
}

extension Objects.File: Decodable {
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
        case "id":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "publicUrl":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "uploadUrl":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown key \(field)."
                )
            )
        }
    }

    

    self.id = map["id"]
self.publicUrl = map["publicUrl"]
self.uploadUrl = map["uploadUrl"]
}
}

extension Fields where TypeLock == Objects.File {


func id() throws -> String {
    let field = GraphQLField.leaf(
     field: "id",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.id[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}
/// Signed URL that should be used to upload the file.

func uploadUrl() throws -> String {
    let field = GraphQLField.leaf(
     field: "uploadUrl",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.uploadUrl[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}
/// URL that may be used to access the file.

func publicUrl() throws -> String {
    let field = GraphQLField.leaf(
     field: "publicUrl",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.publicUrl[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}
}
extension Selection where TypeLock == Never, Type == Never {
    typealias File<T> = Selection<T, Objects.File>
}
extension Objects {
struct Subscription {
    let __typename: TypeName = .subscription
    

    enum TypeName: String, Codable {
case subscription = "Subscription"
}
}
}

extension Objects.Subscription: Decodable {
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
        
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown key \(field)."
                )
            )
        }
    }

    

    
}
}

extension Fields where TypeLock == Objects.Subscription {

}

extension Objects {
struct Message {
    let __typename: TypeName = .message
    let author: [String: Objects.User]
let id: [String: String]
let image: [String: Objects.File]
let message: [String: String]

    enum TypeName: String, Codable {
case message = "Message"
}
}
}

extension Objects.Message: Decodable {
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
        case "author":
    if let value = try container.decode(Objects.User?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "id":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "image":
    if let value = try container.decode(Objects.File?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "message":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown key \(field)."
                )
            )
        }
    }

    

    self.author = map["author"]
self.id = map["id"]
self.image = map["image"]
self.message = map["message"]
}
}

extension Fields where TypeLock == Objects.Message {


func id() throws -> String {
    let field = GraphQLField.leaf(
     field: "id",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.id[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}


func message() throws -> String {
    let field = GraphQLField.leaf(
     field: "message",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.message[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}


func image<T>(selection: Selection<T, Objects.File>) throws -> T {
    let field = GraphQLField.composite(
     field: "image",
     type: "File",
     arguments: [  ],
     selection: selection.selection()
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.image[field.alias!] {
    return try selection.decode(data: data)
}
throw SelectionError.badpayload
    case .mocking:
        return try selection.mock()
    }
}


func author<T>(selection: Selection<T, Objects.User>) throws -> T {
    let field = GraphQLField.composite(
     field: "author",
     type: "User",
     arguments: [  ],
     selection: selection.selection()
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.author[field.alias!] {
    return try selection.decode(data: data)
}
throw SelectionError.badpayload
    case .mocking:
        return try selection.mock()
    }
}
}
extension Selection where TypeLock == Never, Type == Never {
    typealias Message<T> = Selection<T, Objects.Message>
}
extension Objects.User {


static func id() throws -> Selection<String, Objects.User> {
    Selection<String, Objects.User> {
        try $0.id()
    }
}
/// A nickname user has picked for themself.

static func username() throws -> Selection<String, Objects.User> {
    Selection<String, Objects.User> {
        try $0.username()
    }
}
}

extension Objects.Query {
/// Simple field that always returns "Hello world!".

static func hello() throws -> Selection<String, Objects.Query> {
    Selection<String, Objects.Query> {
        try $0.hello()
    }
}
/// Returns currently authenticated user and errors if there's no authenticated user.

static func user<T>(selection: Selection<T, Objects.User>) throws -> Selection<T, Objects.Query> {
    Selection<T, Objects.Query> {
        try $0.user(selection: selection)
    }
}
/// Returns a list of comics from the Marvel universe.

static func comics<T>(pagination: OptionalArgument<InputObjects.Pagination> = .absent(), selection: Selection<T, [Objects.Comic]>) throws -> Selection<T, Objects.Query> {
    Selection<T, Objects.Query> {
        try $0.comics(pagination: pagination, selection: selection)
    }
}
/// Returns a list of characters from the Marvel universe.

static func characters<T>(pagination: OptionalArgument<InputObjects.Pagination> = .absent(), selection: Selection<T, [Objects.Character]>) throws -> Selection<T, Objects.Query> {
    Selection<T, Objects.Query> {
        try $0.characters(pagination: pagination, selection: selection)
    }
}
/// Searches all characters and comics by name and returns those whose
/// name starts with the query string.

static func search<T>(query: InputObjects.Search , pagination: OptionalArgument<InputObjects.Pagination> = .absent(), selection: Selection<T, [Unions.SearchResult]>) throws -> Selection<T, Objects.Query> {
    Selection<T, Objects.Query> {
        try $0.search(query: query, pagination: pagination, selection: selection)
    }
}
}

extension Objects.Character {


static func id() throws -> Selection<String, Objects.Character> {
    Selection<String, Objects.Character> {
        try $0.id()
    }
}


static func name() throws -> Selection<String, Objects.Character> {
    Selection<String, Objects.Character> {
        try $0.name()
    }
}


static func description() throws -> Selection<String, Objects.Character> {
    Selection<String, Objects.Character> {
        try $0.description()
    }
}
/// URL of the character image.

static func image() throws -> Selection<String, Objects.Character> {
    Selection<String, Objects.Character> {
        try $0.image()
    }
}
/// Tells whether currently authenticated user has starred this character.
/// NOTE: If there's no authenticated user, this field will always return false.

static func starred() throws -> Selection<Bool, Objects.Character> {
    Selection<Bool, Objects.Character> {
        try $0.starred()
    }
}
}

extension Objects.Comic {


static func id() throws -> Selection<String, Objects.Comic> {
    Selection<String, Objects.Comic> {
        try $0.id()
    }
}


static func title() throws -> Selection<String, Objects.Comic> {
    Selection<String, Objects.Comic> {
        try $0.title()
    }
}


static func description() throws -> Selection<String, Objects.Comic> {
    Selection<String, Objects.Comic> {
        try $0.description()
    }
}


static func isbn() throws -> Selection<String, Objects.Comic> {
    Selection<String, Objects.Comic> {
        try $0.isbn()
    }
}
/// URL of the thumbnail image.

static func thumbnail() throws -> Selection<String, Objects.Comic> {
    Selection<String, Objects.Comic> {
        try $0.thumbnail()
    }
}


static func pageCount() throws -> Selection<Int?, Objects.Comic> {
    Selection<Int?, Objects.Comic> {
        try $0.pageCount()
    }
}
/// Tells whether currently authenticated user has starred this comic.

static func starred() throws -> Selection<Bool, Objects.Comic> {
    Selection<Bool, Objects.Comic> {
        try $0.starred()
    }
}
}

extension Objects.Mutation {
/// Creates a random authentication session.

static func auth<T>(selection: Selection<T, Unions.AuthPayload>) throws -> Selection<T, Objects.Mutation> {
    Selection<T, Objects.Mutation> {
        try $0.auth(selection: selection)
    }
}
/// Adds a star to a comic or a character.

static func star<T>(id: String , item: Enums.Item , selection: Selection<T, Unions.SearchResult>) throws -> Selection<T, Objects.Mutation> {
    Selection<T, Objects.Mutation> {
        try $0.star(id: id, item: item, selection: selection)
    }
}
/// Creates a new upload URL for a file and returns an ID.
/// NOTE: The file should be uploaded to the returned URL. If the user is not
/// authenticated, mutation will throw an error.

static func uploadFile<T>(contentType: String , `extension`: OptionalArgument<String> = .absent(), folder: String , selection: Selection<T, Objects.File>) throws -> Selection<T, Objects.Mutation> {
    Selection<T, Objects.Mutation> {
        try $0.uploadFile(contentType: contentType, `extension`: `extension`, folder: folder, selection: selection)
    }
}
}

extension Objects.AuthPayloadSuccess {


static func token() throws -> Selection<String, Objects.AuthPayloadSuccess> {
    Selection<String, Objects.AuthPayloadSuccess> {
        try $0.token()
    }
}


static func user<T>(selection: Selection<T, Objects.User>) throws -> Selection<T, Objects.AuthPayloadSuccess> {
    Selection<T, Objects.AuthPayloadSuccess> {
        try $0.user(selection: selection)
    }
}
}

extension Objects.AuthPayloadFailure {


static func message() throws -> Selection<String, Objects.AuthPayloadFailure> {
    Selection<String, Objects.AuthPayloadFailure> {
        try $0.message()
    }
}
}

extension Objects.File {


static func id() throws -> Selection<String, Objects.File> {
    Selection<String, Objects.File> {
        try $0.id()
    }
}
/// Signed URL that should be used to upload the file.

static func uploadUrl() throws -> Selection<String, Objects.File> {
    Selection<String, Objects.File> {
        try $0.uploadUrl()
    }
}
/// URL that may be used to access the file.

static func publicUrl() throws -> Selection<String, Objects.File> {
    Selection<String, Objects.File> {
        try $0.publicUrl()
    }
}
}

extension Objects.Subscription {

}
extension Selection where TypeLock == Never, Type == Never {
    typealias Subscription = Objects.Subscription
}
extension Objects.Message {


static func id() throws -> Selection<String, Objects.Message> {
    Selection<String, Objects.Message> {
        try $0.id()
    }
}


static func message() throws -> Selection<String, Objects.Message> {
    Selection<String, Objects.Message> {
        try $0.message()
    }
}


static func image<T>(selection: Selection<T, Objects.File>) throws -> Selection<T, Objects.Message> {
    Selection<T, Objects.Message> {
        try $0.image(selection: selection)
    }
}


static func author<T>(selection: Selection<T, Objects.User>) throws -> Selection<T, Objects.Message> {
    Selection<T, Objects.Message> {
        try $0.author(selection: selection)
    }
}
}


// MARK: - Interfaces
enum Interfaces {}
extension Interfaces {
struct Node {
    let __typename: TypeName
    let author: [String: Objects.User]
let description: [String: String]
let id: [String: String]
let image: [String: Objects.File]
let isbn: [String: String]
let message: [String: String]
let name: [String: String]
let pageCount: [String: Int]
let publicUrl: [String: String]
let starred: [String: Bool]
let thumbnail: [String: String]
let title: [String: String]
let uploadUrl: [String: String]
let username: [String: String]

    enum TypeName: String, Codable {
case user = "User"
case character = "Character"
case comic = "Comic"
case file = "File"
case message = "Message"
}
}
}

extension Interfaces.Node: Decodable {
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
        case "author":
    if let value = try container.decode(Objects.User?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "description":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "id":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "image":
    if let value = try container.decode(Objects.File?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "isbn":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "message":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "name":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "pageCount":
    if let value = try container.decode(Int?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "publicUrl":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "starred":
    if let value = try container.decode(Bool?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "thumbnail":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "title":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "uploadUrl":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "username":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown key \(field)."
                )
            )
        }
    }

    self.__typename = try container.decode(TypeName.self, forKey: DynamicCodingKeys(stringValue: "__typename")!)

    self.author = map["author"]
self.description = map["description"]
self.id = map["id"]
self.image = map["image"]
self.isbn = map["isbn"]
self.message = map["message"]
self.name = map["name"]
self.pageCount = map["pageCount"]
self.publicUrl = map["publicUrl"]
self.starred = map["starred"]
self.thumbnail = map["thumbnail"]
self.title = map["title"]
self.uploadUrl = map["uploadUrl"]
self.username = map["username"]
}
}

extension Fields where TypeLock == Interfaces.Node {
/// ID of the object.

func id() throws -> String {
    let field = GraphQLField.leaf(
     field: "id",
     arguments: [  ]
)
    self.select(field)

    switch self.state {
    case .decoding(let data):
        if let data = data.id[field.alias!] {
    return data
}
throw SelectionError.badpayload
    case .mocking:
        return String.mockValue
    }
}
}

extension Fields where TypeLock == Interfaces.Node {
    func on<T>(user: Selection<T, Objects.User>, character: Selection<T, Objects.Character>, comic: Selection<T, Objects.Comic>, file: Selection<T, Objects.File>, message: Selection<T, Objects.Message>) throws -> T {
        self.select([GraphQLField.fragment(type: "User", interface: "Interfaces.Node", selection: user.selection()),
GraphQLField.fragment(type: "Character", interface: "Interfaces.Node", selection: character.selection()),
GraphQLField.fragment(type: "Comic", interface: "Interfaces.Node", selection: comic.selection()),
GraphQLField.fragment(type: "File", interface: "Interfaces.Node", selection: file.selection()),
GraphQLField.fragment(type: "Message", interface: "Interfaces.Node", selection: message.selection())])

        switch self.state {
        case .decoding(let data):
            switch data.__typename {
            case .user:
    let data = Objects.User(id: data.id, username: data.username)
    return try user.decode(data: data)
case .character:
    let data = Objects.Character(description: data.description, id: data.id, image: data.image, name: data.name, starred: data.starred)
    return try character.decode(data: data)
case .comic:
    let data = Objects.Comic(description: data.description, id: data.id, isbn: data.isbn, pageCount: data.pageCount, starred: data.starred, thumbnail: data.thumbnail, title: data.title)
    return try comic.decode(data: data)
case .file:
    let data = Objects.File(id: data.id, publicUrl: data.publicUrl, uploadUrl: data.uploadUrl)
    return try file.decode(data: data)
case .message:
    let data = Objects.Message(author: data.author, id: data.id, image: data.image, message: data.message)
    return try message.decode(data: data)
            }
        case .mocking:
            return try user.mock()
        }
    }
}

extension Selection where TypeLock == Never, Type == Never {
    typealias Node<T> = Selection<T, Interfaces.Node>
}

// MARK: - Unions
enum Unions {}
extension Unions {
struct SearchResult {
    let __typename: TypeName
    let description: [String: String]
let id: [String: String]
let image: [String: String]
let isbn: [String: String]
let name: [String: String]
let pageCount: [String: Int]
let starred: [String: Bool]
let thumbnail: [String: String]
let title: [String: String]

    enum TypeName: String, Codable {
case character = "Character"
case comic = "Comic"
}
}
}

extension Unions.SearchResult: Decodable {
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
        case "description":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "id":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "image":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "isbn":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "name":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "pageCount":
    if let value = try container.decode(Int?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "starred":
    if let value = try container.decode(Bool?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "thumbnail":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "title":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown key \(field)."
                )
            )
        }
    }

    self.__typename = try container.decode(TypeName.self, forKey: DynamicCodingKeys(stringValue: "__typename")!)

    self.description = map["description"]
self.id = map["id"]
self.image = map["image"]
self.isbn = map["isbn"]
self.name = map["name"]
self.pageCount = map["pageCount"]
self.starred = map["starred"]
self.thumbnail = map["thumbnail"]
self.title = map["title"]
}
}

extension Fields where TypeLock == Unions.SearchResult {
    func on<T>(character: Selection<T, Objects.Character>, comic: Selection<T, Objects.Comic>) throws -> T {
        self.select([GraphQLField.fragment(type: "Character", interface: "Unions.SearchResult", selection: character.selection()),
GraphQLField.fragment(type: "Comic", interface: "Unions.SearchResult", selection: comic.selection())])

        switch self.state {
        case .decoding(let data):
            switch data.__typename {
            case .character:
    let data = Objects.Character(description: data.description, id: data.id, image: data.image, name: data.name, starred: data.starred)
    return try character.decode(data: data)
case .comic:
    let data = Objects.Comic(description: data.description, id: data.id, isbn: data.isbn, pageCount: data.pageCount, starred: data.starred, thumbnail: data.thumbnail, title: data.title)
    return try comic.decode(data: data)
            }
        case .mocking:
            return try character.mock()
        }
    }
}

extension Selection where TypeLock == Never, Type == Never {
    typealias SearchResult<T> = Selection<T, Unions.SearchResult>
}
extension Unions {
struct AuthPayload {
    let __typename: TypeName
    let message: [String: String]
let token: [String: String]
let user: [String: Objects.User]

    enum TypeName: String, Codable {
case authPayloadSuccess = "AuthPayloadSuccess"
case authPayloadFailure = "AuthPayloadFailure"
}
}
}

extension Unions.AuthPayload: Decodable {
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
        case "message":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "token":
    if let value = try container.decode(String?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
case "user":
    if let value = try container.decode(Objects.User?.self, forKey: codingKey) {
        map.set(key: field, hash: alias, value: value as Any)
    }
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown key \(field)."
                )
            )
        }
    }

    self.__typename = try container.decode(TypeName.self, forKey: DynamicCodingKeys(stringValue: "__typename")!)

    self.message = map["message"]
self.token = map["token"]
self.user = map["user"]
}
}

extension Fields where TypeLock == Unions.AuthPayload {
    func on<T>(authPayloadSuccess: Selection<T, Objects.AuthPayloadSuccess>, authPayloadFailure: Selection<T, Objects.AuthPayloadFailure>) throws -> T {
        self.select([GraphQLField.fragment(type: "AuthPayloadSuccess", interface: "Unions.AuthPayload", selection: authPayloadSuccess.selection()),
GraphQLField.fragment(type: "AuthPayloadFailure", interface: "Unions.AuthPayload", selection: authPayloadFailure.selection())])

        switch self.state {
        case .decoding(let data):
            switch data.__typename {
            case .authPayloadSuccess:
    let data = Objects.AuthPayloadSuccess(token: data.token, user: data.user)
    return try authPayloadSuccess.decode(data: data)
case .authPayloadFailure:
    let data = Objects.AuthPayloadFailure(message: data.message)
    return try authPayloadFailure.decode(data: data)
            }
        case .mocking:
            return try authPayloadSuccess.mock()
        }
    }
}

extension Selection where TypeLock == Never, Type == Never {
    typealias AuthPayload<T> = Selection<T, Unions.AuthPayload>
}

// MARK: - Enums
enum Enums {}
extension Enums {
    /// Item
    enum Item: String, CaseIterable, Codable {
    

case character = "CHARACTER"


case comic = "COMIC"
    }
}

// MARK: - Input Objects
enum InputObjects {}
extension InputObjects {
    struct Pagination: Encodable, Hashable {

    
var offset: OptionalArgument<Int>  = .absent()
/// Number of items in a list that should be returned.
/// NOTE: Maximum is 20 items.
var take: OptionalArgument<Int>  = .absent()

    func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    if offset.hasValue { try container.encode(offset, forKey: .offset) }
if take.hasValue { try container.encode(take, forKey: .take) }
}
    
    enum CodingKeys: String, CodingKey {
case offset = "offset"
case take = "take"
}
    }
}
extension InputObjects {
    struct Search: Encodable, Hashable {

    /// String used to compare the name of the item to.
var query: String 

var pagination: OptionalArgument<InputObjects.Pagination>  = .absent()

    func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(query, forKey: .query)
if pagination.hasValue { try container.encode(pagination, forKey: .pagination) }
}
    
    enum CodingKeys: String, CodingKey {
case query = "query"
case pagination = "pagination"
}
    }
}