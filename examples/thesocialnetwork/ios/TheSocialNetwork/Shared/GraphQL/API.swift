// This file was auto-generated using maticzav/swift-graphql. DO NOT EDIT MANUALLY!
import Foundation
import GraphQL
import SwiftGraphQL

// MARK: - Operations
public enum Operations {}
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
public enum Objects {}
extension Objects {
  public struct Query {}
}

extension Fields where TypeLock == Objects.Query {

  public func viewer<T>(selection: Selection<T, Objects.User?>) throws -> T {
    let field = GraphQLField.composite(
      field: "viewer",
      parent: "Query",
      type: "User",
      arguments: [],
      selection: selection.__selection()
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try selection.__decode(data: $0) }
    case .selecting:
      return try selection.__mock()
    }
  }
  /// A sample list of random strings.

  public func feed<T>(selection: Selection<T, [Objects.Message]>) throws -> T {
    let field = GraphQLField.composite(
      field: "feed",
      parent: "Query",
      type: "Message",
      arguments: [],
      selection: selection.__selection()
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try selection.__decode(data: $0) }
    case .selecting:
      return try selection.__mock()
    }
  }
}
extension Selection where T == Never, TypeLock == Never {
  public typealias Query<T> = Selection<T, Objects.Query>
}
extension Objects {
  public struct Mutation {}
}

extension Fields where TypeLock == Objects.Mutation {
  /// A mutation that returns the token that may be used to authenticate the user.

  public func login<T>(
    username: String, password: String, selection: Selection<T, Unions.AuthPayload>
  ) throws -> T {
    let field = GraphQLField.composite(
      field: "login",
      parent: "Mutation",
      type: "AuthPayload",
      arguments: [
        Argument(name: "username", type: "String!", value: username),
        Argument(name: "password", type: "String!", value: password),
      ],
      selection: selection.__selection()
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try selection.__decode(data: $0) }
    case .selecting:
      return try selection.__mock()
    }
  }
  /// A mutation that lets you send a message to the feed.

  public func message<T>(message: String, selection: Selection<T, Objects.Message?>) throws -> T {
    let field = GraphQLField.composite(
      field: "message",
      parent: "Mutation",
      type: "Message",
      arguments: [Argument(name: "message", type: "String!", value: message)],
      selection: selection.__selection()
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try selection.__decode(data: $0) }
    case .selecting:
      return try selection.__mock()
    }
  }
  /// Returns an URL that may be used to upload the user image.

  public func getProfilePictureSignedUrl<T>(
    `extension`: String, contentType: String, selection: Selection<T, Objects.SignedUrl?>
  ) throws -> T {
    let field = GraphQLField.composite(
      field: "getProfilePictureSignedURL",
      parent: "Mutation",
      type: "SignedURL",
      arguments: [
        Argument(name: "extension", type: "String!", value: `extension`),
        Argument(name: "contentType", type: "String!", value: contentType),
      ],
      selection: selection.__selection()
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try selection.__decode(data: $0) }
    case .selecting:
      return try selection.__mock()
    }
  }
  /// Updates the profile picture of currently authenticated user.

  public func setProfilePicture<T>(file: String, selection: Selection<T, Objects.User?>) throws -> T
  {
    let field = GraphQLField.composite(
      field: "setProfilePicture",
      parent: "Mutation",
      type: "User",
      arguments: [Argument(name: "file", type: "ID!", value: file)],
      selection: selection.__selection()
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try selection.__decode(data: $0) }
    case .selecting:
      return try selection.__mock()
    }
  }
}
extension Selection where T == Never, TypeLock == Never {
  public typealias Mutation<T> = Selection<T, Objects.Mutation>
}
extension Objects {
  public struct AuthPayloadSuccess {}
}

extension Fields where TypeLock == Objects.AuthPayloadSuccess {

  public func token() throws -> String {
    let field = GraphQLField.leaf(
      field: "token",
      parent: "AuthPayloadSuccess",
      arguments: []
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try String(from: $0) }
    case .selecting:
      return String.mockValue
    }
  }
}
extension Selection where T == Never, TypeLock == Never {
  public typealias AuthPayloadSuccess<T> = Selection<T, Objects.AuthPayloadSuccess>
}
extension Objects {
  public struct AuthPayloadFailure {}
}

extension Fields where TypeLock == Objects.AuthPayloadFailure {

  public func message() throws -> String {
    let field = GraphQLField.leaf(
      field: "message",
      parent: "AuthPayloadFailure",
      arguments: []
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try String(from: $0) }
    case .selecting:
      return String.mockValue
    }
  }
}
extension Selection where T == Never, TypeLock == Never {
  public typealias AuthPayloadFailure<T> = Selection<T, Objects.AuthPayloadFailure>
}
extension Objects {
  public struct SignedUrl {}
}

extension Fields where TypeLock == Objects.SignedUrl {

  public func fileId() throws -> String {
    let field = GraphQLField.leaf(
      field: "file_id",
      parent: "SignedURL",
      arguments: []
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try String(from: $0) }
    case .selecting:
      return String.mockValue
    }
  }

  public func uploadUrl() throws -> String {
    let field = GraphQLField.leaf(
      field: "upload_url",
      parent: "SignedURL",
      arguments: []
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try String(from: $0) }
    case .selecting:
      return String.mockValue
    }
  }

  public func fileUrl() throws -> String {
    let field = GraphQLField.leaf(
      field: "file_url",
      parent: "SignedURL",
      arguments: []
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try String(from: $0) }
    case .selecting:
      return String.mockValue
    }
  }
}
extension Selection where T == Never, TypeLock == Never {
  public typealias SignedUrl<T> = Selection<T, Objects.SignedUrl>
}
extension Objects {
  public struct Subscription {}
}

extension Fields where TypeLock == Objects.Subscription {
  /// Simple subscription that tells current time every second.

  public func time() throws -> Date {
    let field = GraphQLField.leaf(
      field: "time",
      parent: "Subscription",
      arguments: []
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try Date(from: $0) }
    case .selecting:
      return Date.mockValue
    }
  }
  /// Number of new messages since the last fetch.

  public func messages() throws -> Int {
    let field = GraphQLField.leaf(
      field: "messages",
      parent: "Subscription",
      arguments: []
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try Int(from: $0) }
    case .selecting:
      return Int.mockValue
    }
  }
}

extension Objects {
  public struct User {}
}

extension Fields where TypeLock == Objects.User {

  public func id() throws -> String {
    let field = GraphQLField.leaf(
      field: "id",
      parent: "User",
      arguments: []
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try String(from: $0) }
    case .selecting:
      return String.mockValue
    }
  }

  public func username() throws -> String {
    let field = GraphQLField.leaf(
      field: "username",
      parent: "User",
      arguments: []
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try String(from: $0) }
    case .selecting:
      return String.mockValue
    }
  }

  public func picture() throws -> String? {
    let field = GraphQLField.leaf(
      field: "picture",
      parent: "User",
      arguments: []
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try String?(from: $0) }
    case .selecting:
      return nil
    }
  }

  public func isViewer() throws -> Bool {
    let field = GraphQLField.leaf(
      field: "isViewer",
      parent: "User",
      arguments: []
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try Bool(from: $0) }
    case .selecting:
      return Bool.mockValue
    }
  }
}
extension Selection where T == Never, TypeLock == Never {
  public typealias User<T> = Selection<T, Objects.User>
}
extension Objects {
  public struct Message {}
}

extension Fields where TypeLock == Objects.Message {

  public func id() throws -> String {
    let field = GraphQLField.leaf(
      field: "id",
      parent: "Message",
      arguments: []
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try String(from: $0) }
    case .selecting:
      return String.mockValue
    }
  }

  public func createdAt() throws -> Date {
    let field = GraphQLField.leaf(
      field: "createdAt",
      parent: "Message",
      arguments: []
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try Date(from: $0) }
    case .selecting:
      return Date.mockValue
    }
  }

  public func message() throws -> String {
    let field = GraphQLField.leaf(
      field: "message",
      parent: "Message",
      arguments: []
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try String(from: $0) }
    case .selecting:
      return String.mockValue
    }
  }

  public func sender<T>(selection: Selection<T, Objects.User>) throws -> T {
    let field = GraphQLField.composite(
      field: "sender",
      parent: "Message",
      type: "User",
      arguments: [],
      selection: selection.__selection()
    )
    self.__select(field)

    switch self.__state {
    case .decoding:
      return try self.__decode(field: field.alias!) { try selection.__decode(data: $0) }
    case .selecting:
      return try selection.__mock()
    }
  }
}
extension Selection where T == Never, TypeLock == Never {
  public typealias Message<T> = Selection<T, Objects.Message>
}
extension Objects.Query {

  public static func viewer<T>(selection: Selection<T, Objects.User?>) -> Selection<
    T, Objects.Query
  > {
    Selection<T, Objects.Query> {
      try $0.viewer(selection: selection)
    }
  }
  /// A sample list of random strings.

  public static func feed<T>(selection: Selection<T, [Objects.Message]>) -> Selection<
    T, Objects.Query
  > {
    Selection<T, Objects.Query> {
      try $0.feed(selection: selection)
    }
  }
}
extension Objects.Mutation {
  /// A mutation that returns the token that may be used to authenticate the user.

  public static func login<T>(
    username: String, password: String, selection: Selection<T, Unions.AuthPayload>
  ) -> Selection<T, Objects.Mutation> {
    Selection<T, Objects.Mutation> {
      try $0.login(username: username, password: password, selection: selection)
    }
  }
  /// A mutation that lets you send a message to the feed.

  public static func message<T>(message: String, selection: Selection<T, Objects.Message?>)
    -> Selection<T, Objects.Mutation>
  {
    Selection<T, Objects.Mutation> {
      try $0.message(message: message, selection: selection)
    }
  }
  /// Returns an URL that may be used to upload the user image.

  public static func getProfilePictureSignedUrl<T>(
    `extension`: String, contentType: String, selection: Selection<T, Objects.SignedUrl?>
  ) -> Selection<T, Objects.Mutation> {
    Selection<T, Objects.Mutation> {
      try $0.getProfilePictureSignedUrl(
        extension: `extension`, contentType: contentType, selection: selection)
    }
  }
  /// Updates the profile picture of currently authenticated user.

  public static func setProfilePicture<T>(file: String, selection: Selection<T, Objects.User?>)
    -> Selection<T, Objects.Mutation>
  {
    Selection<T, Objects.Mutation> {
      try $0.setProfilePicture(file: file, selection: selection)
    }
  }
}
extension Objects.AuthPayloadSuccess {

  public static func token() -> Selection<String, Objects.AuthPayloadSuccess> {
    Selection<String, Objects.AuthPayloadSuccess> {
      try $0.token()
    }
  }
}
extension Objects.AuthPayloadFailure {

  public static func message() -> Selection<String, Objects.AuthPayloadFailure> {
    Selection<String, Objects.AuthPayloadFailure> {
      try $0.message()
    }
  }
}
extension Objects.SignedUrl {

  public static func fileId() -> Selection<String, Objects.SignedUrl> {
    Selection<String, Objects.SignedUrl> {
      try $0.fileId()
    }
  }

  public static func uploadUrl() -> Selection<String, Objects.SignedUrl> {
    Selection<String, Objects.SignedUrl> {
      try $0.uploadUrl()
    }
  }

  public static func fileUrl() -> Selection<String, Objects.SignedUrl> {
    Selection<String, Objects.SignedUrl> {
      try $0.fileUrl()
    }
  }
}
extension Objects.Subscription {
  /// Simple subscription that tells current time every second.

  public static func time() -> Selection<Date, Objects.Subscription> {
    Selection<Date, Objects.Subscription> {
      try $0.time()
    }
  }
  /// Number of new messages since the last fetch.

  public static func messages() -> Selection<Int, Objects.Subscription> {
    Selection<Int, Objects.Subscription> {
      try $0.messages()
    }
  }
}
extension Objects.User {

  public static func id() -> Selection<String, Objects.User> {
    Selection<String, Objects.User> {
      try $0.id()
    }
  }

  public static func username() -> Selection<String, Objects.User> {
    Selection<String, Objects.User> {
      try $0.username()
    }
  }

  public static func picture() -> Selection<String?, Objects.User> {
    Selection<String?, Objects.User> {
      try $0.picture()
    }
  }

  public static func isViewer() -> Selection<Bool, Objects.User> {
    Selection<Bool, Objects.User> {
      try $0.isViewer()
    }
  }
}
extension Objects.Message {

  public static func id() -> Selection<String, Objects.Message> {
    Selection<String, Objects.Message> {
      try $0.id()
    }
  }

  public static func createdAt() -> Selection<Date, Objects.Message> {
    Selection<Date, Objects.Message> {
      try $0.createdAt()
    }
  }

  public static func message() -> Selection<String, Objects.Message> {
    Selection<String, Objects.Message> {
      try $0.message()
    }
  }

  public static func sender<T>(selection: Selection<T, Objects.User>) -> Selection<
    T, Objects.Message
  > {
    Selection<T, Objects.Message> {
      try $0.sender(selection: selection)
    }
  }
}

// MARK: - Interfaces
public enum Interfaces {}

// MARK: - Unions
public enum Unions {}
extension Unions {
  public struct AuthPayload {}
}

extension Fields where TypeLock == Unions.AuthPayload {
  public func on<T>(
    authPayloadSuccess: Selection<T, Objects.AuthPayloadSuccess>,
    authPayloadFailure: Selection<T, Objects.AuthPayloadFailure>
  ) throws -> T {
    self.__select([
      GraphQLField.fragment(
        type: "AuthPayloadSuccess", interface: "Unions.AuthPayload",
        selection: authPayloadSuccess.__selection()),
      GraphQLField.fragment(
        type: "AuthPayloadFailure", interface: "Unions.AuthPayload",
        selection: authPayloadFailure.__selection()),
    ])

    switch self.__state {
    case .decoding(let data):
      let typename = try self.__decode(field: "__typename") { $0.value as? String }
      switch typename {
      case "AuthPayloadSuccess":
        return try authPayloadSuccess.__decode(data: data)
      case "AuthPayloadFailure":
        return try authPayloadFailure.__decode(data: data)
      default:
        throw ObjectDecodingError.unknownInterfaceType(
          interface: "Unions.AuthPayload", typename: typename)
      }
    case .selecting:
      return try authPayloadSuccess.__mock()
    }
  }
}

extension Selection where T == Never, TypeLock == Never {
  public typealias AuthPayload<T> = Selection<T, Unions.AuthPayload>
}

// MARK: - Enums
public enum Enums {}

// MARK: - Input Objects

/// Utility pointer to InputObjects.
public typealias Inputs = InputObjects

public enum InputObjects {}