# Contributing to SwiftGraphQL

Hey :wave:! This library is a collaborative effort of many people. We are very excited to see you here. This file will help you navigate around more easily.

## Code Organization

SwiftGraphQL is split into multiple packages that serve different purposes.

1. **GraphQLAST** describes the models and methods used for fetching information about the schema,
1. **GraphQLWebSocket** implements a [basic web-socket protocol](https://github.com/enisdenjo/graphql-ws) that may send GraphQL requests over WebSockets,
1. **SwiftGraphQL** is responsible for query creation,
1. **SwiftGraphQLUI** exposes a collection of value modifiers useful in SwiftUI,
1. **SwiftGraphQLCLI** exposes a ready to use CLI tool for code generation.
1. **SwiftGraphQLCodegen** generates methods that you may use to query fields and types of your schema.
