# Contributing to SwiftGraphQL

Hey :wave:! This library is a collaborative effort of many people. We are very excited to see you here. This file will help you navigate around more easily and make sure your pull requests receive attention they deserve.

This package is best developed using Swift command line tools.

SwiftGraphQL depends on `swift-format` that relies on `SwiftSyntax` that is distributed as part of the Swift toolchain. It's important that you set the correct version of Swift Command Line Tools when developing so that the tools match the version of `swift-format` used.

```sh
swift package tools-version --set 5.5
```

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
1. Check _all_ your changes in GitHub files tab before _again_ before requesting a review.
1. Suggest a release type (e.g. patch, minor, major) for your change.

## Building Binary and Documentation

```sh
swift build -c release --product swift-graphql --disable-sandbox
```

> To verify that built binary contains both architectures use `lipo -info` (https://liamnichols.eu/2020/08/01/building-swift-packages-as-a-universal-binary.html).

```sh
swift build -Xswiftc -emit-symbol-graph -Xswiftc -emit-symbol-graph-dir
```
