#  SwiftGraphQLCodegen



My goal is to abstract generator so that we only write extensions for each of the types in SwiftAST to conform to BlockProtocol and use print function as a generator.

Generator contains extensions for necessary GraphQL types so we may generate Swift code from them.

### Philosophy and Design Choices

We generate all of the code into a single file. The main goal is that developers don't have to worry about the generated code - it just works. Having multiple files in Swift source code serves no benefit. We do, however, implement namespaces to make it easier to identify parts of the code, and prevent naming collisions.
