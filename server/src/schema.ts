/**
 * Schema definition of the server.
 */
export const typeDefs = /* GraphQL */ `
  scalar DateTime

  """
  An object with an ID.
  """
  interface Node {
    """
    ID of the object.
    """
    id: ID!
  }

  type User implements Node {
    id: ID!

    """
    A nickname user has picked for themself.
    """
    username: String!

    """
    Profile picture of the user.
    """
    avatarURL: String
  }

  input Pagination {
    offset: Int

    """
    Number of items in a list that should be returned.

    NOTE: Maximum is 20 items.
    """
    take: Int
  }

  input Search {
    """
    String used to compare the name of the item to.
    """
    query: String!

    pagination: Pagination
  }

  # Query

  type Query {
    """
    Simple field that always returns "Hello world!".
    """
    hello: String!

    """
    Returns currently authenticated user and errors if there's no authenticated user.
    """
    user: User!

    """
    Returns a list of comics from the Marvel universe.
    """
    comics(pagination: Pagination): [Comic!]!

    """
    Returns a list of characters from the Marvel universe.
    """
    characters(pagination: Pagination): [Character!]!

    """
    Searches all characters and comics by name and returns those whose
    name starts with the query string.
    """
    search(query: Search!): [SearchResult!]!
  }

  type Character implements Node {
    id: ID!

    name: String!
    description: String!
    imageURL: String!

    """
    Tells whether currently authenticated user has starred this character.

    NOTE: If there's no authenticated user, this field will always return false.
    """
    starred: Boolean!

    """
    List of comics that this character appears in.
    """
    comics: [Comic!]!

    modified: DateTime!
  }

  type Comic implements Node {
    id: ID!

    title: String!
    description: String!
    isbn: String!
    thumbnailURL: String!

    pageCount: Int

    modified: DateTime!

    """
    Tells whether currently authenticated user has starred this comic.
    """
    starred: Boolean!

    """
    Characters that are mentioned in the story.
    """
    characters: [Character!]!
  }

  union SearchResult = Character | Comic

  # Mutation

  type Mutation {
    """
    Logs in a user if it exists already and signs them up otherwise.
    """
    auth(username: String!, password: String): AuthPayload!

    """
    Updates the avatar of the currently authenticated user.
    """
    updateAvatar(id: ID!): User!

    """
    Adds a star to a comic or a character.
    """
    star(id: ID!, item: Item): SearchResult!

    """
    Adds a comment to the shared list of comments.
    """
    message(id: ID!, comment: String!): SearchResult!

    """
    Creates a new upload URL for a file and returns an ID.

    NOTE: The file should be uploaded to the returned URL. If the user is not
    authenticated, mutation will fail.
    """
    uploadFile(contentType: String!, extension: String, folder: String!): File!
  }

  enum Item {
    CHARACTER
    COMIC
  }

  type AuthPayloadSuccess {
    token: String!
  }

  type AuthPayloadFailure {
    message: String!
  }

  union AuthPayload = AuthPayloadSuccess | AuthPayloadFailure

  type File implements Node {
    id: ID!
    url: String!
  }

  # Subscription

  type Subscription {
    """
    Returns the current time from the server and refreshes every second.
    """
    time: DateTime!

    """
    Triggered whene a new comment is added to the shared list of comments.
    """
    commented: Comment!
  }

  type Comment implements Node {
    id: ID!
    message: String!

    author: User!
  }
`
