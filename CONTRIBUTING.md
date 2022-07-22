# Contributing to SwiftGraphQL

Hey :wave:! This library is a collaborative effort of many people. We are very excited to see you here. This file will help you navigate around more easily and make sure your pull requests receive attention they deserve.

## Code Organization

SwiftGraphQL is split into multiple packages that serve different purposes.

1. **GraphQLAST** describes the models and methods used for fetching information about the schema,
1. **GraphQLWebSocket** implements a [basic web-socket protocol](https://github.com/enisdenjo/graphql-ws) that may send GraphQL requests over WebSockets,
1. **SwiftGraphQL** is responsible for query creation,
1. **SwiftGraphQLCLI** exposes a ready to use CLI tool for code generation.
1. **SwiftGraphQLCodegen** generates methods that you may use to query fields and types of your schema.

## Creating a Pull Request

> Every PR should follow a common structure. This way, it's easier for people to navigate the code, look back at the PRs and understand why library has evolved the way it has.

Every PR should follow the next set of guidelines

1. Title should be well-formated (e.g. "Add WebSocket Support for Apple Watch", not "add WS for apple watch").
1. The first comment should clearly outline what you've changed and, if necessary, why.
1. Make sure that comments in the PR and in the code are grammatically correct.
1. Check *all* your changes in GitHub files tab before *again* before requesting a review. 
