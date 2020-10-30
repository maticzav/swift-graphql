<p align="center"><img src="media/thumbnail.png" width="860" /></p>

# 🦅 SwiftGraphQL

> A GraphQL client that lets you forget about GraphQL.


## Why?

__Why bother?__ Simply put, it's going to save you and your team lots of time. There's a high chance that you are currently writing most of your GraphQL queries by hand. If not, there's probably some part of the link from backend to your frontend that you have to do manually. And as you well know, manual work is error-prone. This library is an end to end type-safe. This way, once your app compiles, you know it's going to work.

__Why another GraphQL library?__ There was no other library that would let me fetch my schema, generate the Swift code, build queries in Swift, and easily adapt query results to my model.


## Overview

SwiftGraphQL is a Swift code generator and a GraphQL client. It lets you create queries using Swift, and guarantees that every query you create is valid. Using XCode autocompletion features, you can effortlessly explore the API while creating your Swift application.

I have create this library around three core principles:
    
1. Every query that you may create is valid;
1. If your project compiles, your queries are valid;
1. Use Swift language constructs in favour of GraphQL for a better developer experience (e.g. we should use variables as fragments, functions as parameters, ...)
1. Your server shouldn't define your application model.

Here's a short preview of the code to give you the idea.

```swift
import SwiftGraphQL

// Define a Swift model.
struct Human: Identifiable {
    let id: String
    let name: String
    let homePlanet: String?
}

// Create a selection.
let human = Selection<Human, Objects.Human> {
    Human(
        id: $0.id(), 
        name: $0.name(),
        homePlanet: $0.homePlanet()
    )
}

// Construct a query.
let query = Selection<[Human], Operations.Query> {
    $0.humans(human.list)
}

// Perform the query.
client.send(selection: query) { result in
    if let data = try? result.get() {
        print(data)
    }
}
```

## Features

- ✨ **Intuitive:** You'll forget about the GraphQL layer altogether.
- 🦅 **Swift-First:** It lets you use Swift constructs in favour of GraphQL language.
- 🏖 **Time Saving:** I've built it so you don't have to waste your precous time.
- 🏔 **High Level:** You don't have to worry about naming collisions, variables, _anything_. Just Swift.

## How it works?

It seems like the best way to learn this library is by understanding how it works behind the scenes.

The first concept that you should know about is `Selection`.

The first main concept of SwiftGraphQL are _phantom types_. TLDR; Phantom types let you use Generics to constrain methods to specific types. You can see them at work in the funny looking `Selection<Type, Scope>` parts of the code that let you select what you want to query. You can read more about phantom types [here](https://www.swiftbysundell.com/articles/phantom-types-in-swift/), but for now it suffice to understand that we use `Scope` to limit what you may or may not select in a query.

## Getting started

In the following few sections I want to show you how to set up SwiftGraphQL and create your first query.

We'll create a code generation build step using SwiftPackage executable and explore the API using XCode autocompletion.

## Generating Swift code

First, we need to somehow fetch your GraphQL schema and generate the code specific to your company. We'll do that using 

```swift
import SwiftGraphQLCodegen

let endpoint = URL(string: "http://localhost:5000/")!
let schema = Path.file("")
let target = Path.file("")

let options = GraphQLCodegenOptions(
    namespace: "API"
)

do {
    try GraphQLSchema.downloadFrom(endpoint, to: schema)
    try GraphQLCodegen.generate(target, from: schema)
} catch {
    exit(1)
}
```


## Documentation


## F.A.Q


## Thank you

I want to dedicate this last secion to everyone who helped me along the way. First, I would like to thank Dillon Kearns, the author of elm-graphql, who inspired me to write the library, and helped me understand the core principles behind his Elm version.
I would like to thank Peter Albert for giving me a chance to build this library, having faith that it's possible, and all the conversations that helped me push through the difficult parts of it.
Lastly, I'd like to thank Martijn Walraven, who helped me understand how Apollo GraphQL works.


### Licence

MIT @ Matic Zavadlal