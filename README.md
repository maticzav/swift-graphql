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

SwiftGraphQL is a Swift code generator and a lightweight GraphQL client. It lets you create queries using Swift, and guarantees that every query you create is valid.

The library is centered around three core principles:

- 🚀 If your project compiles, your queries work.
- 🦉 Use Swift in favour of GraphQL wherever possible.
- 🌳 Your application model should be independent of your schema.

Here's a short preview of the SwiftGraphQL code

```swift
import SwiftGraphQL

// Define a Swift model.
struct Human: Identifiable {
    let id: String
    let name: String
    let homePlanet: String?
}

// Create a selection.
let human = Selection.Human<Human> {
    Human(
        id: try $0.id(),
        name: try $0.name(),
        homePlanet: try $0.homePlanet()
    )
}

// Construct a query.
let query = Selection.Query<[Human]> {
    try $0.humans(human.list)
}

// Perform the query.
send(query, to: "http://swift-graphql.heroku.com") { result in
    if let data = try? result.get() {
        print(data) // [Human]
    }
}
```

## Documentation

You can find detailed documentation on the SwiftGraphQL page at [https://www.swift-graphql.com/](https://www.swift-graphql.com/).

---

## Development Setup

This package is best developed using Swift command line tools. 

SwiftGraphQL depends on `swift-format` that relies on `SwiftSyntax` that is distributed as part of the Swift toolchain. It's important that you set the correct version of Swift Command Line Tools when developing so that the tools match the version of `swift-format` used.

```sh
swift package tools-version --set 5.5
```

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
