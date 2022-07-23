<div align="center">
<img src="media/thumbnail.png" width="240" />
</div>

> A GraphQL client that lets you forget about GraphQL.

![CI Tests](https://github.com/maticzav/swift-graphql/workflows/Test/badge.svg)

https://graphql.org/swapi-graphql/

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
- 🌳 Your application model should be independent of your schema.
- 🕊 Packages shouldn't lock you in to the "framework".

> You can use only parts of SwiftGraphQL that are useful to you (e.g. use GraphQLWebSocket implementation but not the query builder, or WebSocket but not the client).

## Documentation

You can find detailed documentation on the SwiftGraphQL page at [https://www.swift-graphql.com/](https://www.swift-graphql.com/).

### Other Libraries

SwiftGraphQL solves a set of specific problems but it doesn't solve _every_ problem. Depending on your needs, you may also want to check out

- https://github.com/relay-tools/Relay.swift
- https://github.com/apollographql/apollo-ios
- https://github.com/nerdsupremacist/Graphaello

---

## Thank you

I want to dedicate this last section to everyone who helped me along the way.

- First, I would like to thank Dillon Kearns, the author of [elm-graphql](http://github.com/dillonkearns/elm-graphql), who inspired me to write the library, and helped me understand the core principles behind his Elm version.
- Second, I would like to thank Peter Albert for giving me a chance to build this library, having faith that it's possible, and all the conversations that helped me push through the difficult parts of it.
- Lastly, I'd like to thank every contributor to the project. SwiftGraphQL is better because of you. Thank you!

Thank you! 🙌

---

## License

MIT @ Matic Zavadlal

https://steipete.com/posts/logging-in-swift/
