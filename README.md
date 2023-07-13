<div align="center">
<img src="media/thumbnail.png" width="240" />
</div>

> A GraphQL client that lets you forget about GraphQL.

![CI Tests](https://github.com/maticzav/swift-graphql/workflows/Test/badge.svg)

[www.swift-graphql.com](https://www.swift-graphql.com)

## Features

- ✨ **Intuitive:** You'll forget about the GraphQL layer altogether.
- 🏖 **Time Saving:** I've built it so you don't have to waste your precious time.
- ☝️ **Generate once:** Only when your schema changes.
- ☎️ **Subscriptions:** Listen to subscriptions using webhooks.
- 🏔 **High Level:** You don't have to worry about naming collisions, variables, _anything_. Just Swift.

## Overview

SwiftGraphQL is a GraphQL Client that ships with a type-safe query builder. It lets you perform queries, mutations and listen for subscriptions. The query builder guarantees that every query you _can_ create is valid and complies with the GraphQL spec.

The library is centered around three core principles:

- 🚀 If your project compiles, your queries work.
- 🦉 Use Swift in favour of GraphQL wherever possible.
- 🕊 Packages shouldn't lock you in to the "framework".

> You can use only parts of SwiftGraphQL that are useful to you (e.g. use GraphQLWebSocket implementation but not the query builder, or WebSocket but not the client).

## Documentation

You can find detailed documentation on the SwiftGraphQL page at [www.swift-graphql.com](https://www.swift-graphql.com).

## Examples

You can find examples of how to use a local GraphQL API or remote one in the `/examples` directory.

- _thesocialnetwork_ - a simple chat app that shows how to `swift-graphql` with queries and subscriptions,
- _GitHubStars_ - shows how to use GitHub API with `swift-graphql`.

### Other Libraries

SwiftGraphQL solves a set of specific problems but it doesn't solve _every_ problem. Depending on your needs, you may also want to check out

- https://github.com/relay-tools/Relay.swift
- https://github.com/apollographql/apollo-ios
- https://github.com/nerdsupremacist/Graphaello

---

## Thank you

I would like to dedicate this last section to everyone who helped develop this library.

- First, I would like to thank Dillon Kearns, the author of [elm-graphql](http://github.com/dillonkearns/elm-graphql), who inspired me to write the library, and helped me understand the core principles behind his Elm version.
- Second, I would like to thank Peter Albert for giving me a chance to build this library, having faith that it's possible, and all the conversations that helped me push through the difficult parts of it.
- Thirdly, special thanks to Phil Pluckthun who explained all the bits of how `urql` and `wonka` work,
- Fourthly, thanks to Orta Therox for helping me navigate Combine.
- Lastly, I'd like to thank every contributor to the project. SwiftGraphQL is better because of you. Thank you!

Thank you! 🙌

---

## License

MIT @ Matic Zavadlal
