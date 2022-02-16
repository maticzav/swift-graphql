<div align="center">
<img src="media/thumbnail.png" width="240" />
</div>

> A GraphQL client that lets you forget about GraphQL.

![CI Tests](https://github.com/maticzav/swift-graphql/workflows/Test/badge.svg)

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

## Roadmap and Contributing

This library is feature complete for our use case. We are actively using it in our production applications and plan to expand it as our needs change. We'll also publish performance updates and bug fixes that we find.

I plan to actively maintain it for many upcoming years. Swift seems like a fantastic language and I've only started learning it.

Feel free to create a pull request with future improvements. Please, document your contributions well, and clearly outline the benefits of the change. It's also very helpful to include the ideas behind changes.

> PS.: PRs for the above features will be reviewed a lot more quickly!

## Development Setup

This package is best developed using Swift command line tools. It's important that you set the correct version of Swift Command Line Tools when using the package.

To develop new features for the package I suggest you open `examples/StarWars/StarWars.xcworkspace` workspace. There you can find all schemas used to run and test the app as well as the real-world application example.

## Thank you

I want to dedicate this last section to everyone who helped me along the way.

- First, I would like to thank Dillon Kearns, the author of [elm-graphql](http://github.com/dillonkearns/elm-graphql), who inspired me to write the library, and helped me understand the core principles behind his Elm version.
- Second, I would like to thank Peter Albert for giving me a chance to build this library, having faith that it's possible, and all the conversations that helped me push through the difficult parts of it.
- Lastly, I'd like to thank every contributor to the project. SwiftGraphQL is better because of you. Thank you!

Thank you! 🙌

---

## License

MIT @ Matic Zavadlal
