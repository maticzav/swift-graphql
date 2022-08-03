# Contributing to SwiftGraphQL

Hey :wave:! This library is a collaborative effort of many people and we are all very excited to see you here. This file will help you navigate around more easily and make sure your pull requests receive attention they deserve.

This package is best developed using Swift command line tools.

> NOTE: SwiftGraphQL depends on `swift-format` that relies on `SwiftSyntax` that is distributed as part of the Swift toolchain. It's important that you set the correct version of Swift Command Line Tools when developing so that the tools match the version of `swift-format` used.

```sh
swift package tools-version --set 5.5
```

## Code Organization

SwiftGraphQL is split into multiple packages that serve different purposes.

1. **GraphQL** contains the structures that appear in all GraphQL requests,
1. **GraphQLAST** describes the models and methods used for fetching information about the schema,
1. **GraphQLWebSocket** implements a [GraphQL over WebSocket protocol](https://github.com/enisdenjo/graphql-ws),
1. **SwiftGraphQL** is a query builder library,
1. **SwiftGraphQLCodegen** generates methods that you may use to build type-safe queries,
1. **SwiftGraphQLCLI** exposes a ready to use CLI tool for code generation.

## Roadmap

Feel free to contribute in any way possible. We are excited about your ideas and want to share them with the rest of the world. It's often even more helpful to write a well documented idea than to write code because ["code is the easy part"](https://www.youtube.com/watch?v=DSjbTC-hvqQ).

We are currently investing our efforts into

- Swift Docc Reference of the library,
- Normalized Caching exchange,
- Subscriptions over SSE exchange,
- SwiftUI bindings

Contributing in any of these topics will get a lot of attention and have top priority.

> If you have any questions about the library, feel free to reach out to Matic at `matic.zavadlal [at] gmail.com`.

## Creating a Pull Request

> Every PR should follow a common structure. This way, it's easier for people to navigate the code, look back at the PRs and understand why library has evolved the way it has.

Every PR should follow the next set of guidelines

1. Title should be well-formated (e.g. "Add WebSocket Support for Apple Watch", not "add WS for apple watch").
1. The first comment should clearly outline what you've changed and, if necessary, why.
1. Make sure that comments in the PR and in the code are grammatically correct.
1. Check _all_ your changes in GitHub files tab before _again_ before requesting a review.
1. Suggest a release type (e.g. patch, minor, major) for your change.

## Building Binary and Documentation

```sh
swift build -c release --product swift-graphql --disable-sandbox
```
