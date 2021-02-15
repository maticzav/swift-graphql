<div align="center"><img src="media/thumbnail.png" width="860" /></div>

# 🦅 SwiftGraphQL

> A GraphQL client that lets you forget about GraphQL.

## Features

- ✨ **Intuitive:** You'll forget about the GraphQL layer altogether.
- 🏖 **Time Saving:** I've built it so you don't have to waste your precious time.
- ☝️ **Generate once:** Only when your schema changes.
- ☎️ **Support subscriptions:** Listen to subscriptions using webhooks.
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
let human = Selection.Human {
    Human(
        id: try $0.id(),
        name: try $0.name(),
        homePlanet: try $0.homePlanet()
    )
}

// Construct a query.
let query = Selection.Query {
    try $0.humans(human.list)
}

// Perform the query.
send(query, to: "http://swift-graphql.heroku.com") { result in
    if let data = try? result.get() {
        print(data) // [Human]
    }
}
```

## Installation

Make sure Xcode 11+ is installed first. Installation consists of two parts; you need to include the client in your iOS/macOS project, and locally generate the code using code generator.

#### Installing SwiftGraphQL Client

To install it using Swift Package Manager, open the following menu item in Xcode:

File > Swift Packages > Add Package Dependency...

In the Choose Package Repository prompt add this url:

```
https://github.com/maticzav/swift-graphql/
```

Then press Next and complete the remaining steps. You should select `SwiftGraphQL` as a dependency, since that includes the client code.

To learn more about Swift Package Manager, check out the [official documentation](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

### Installing Code Generator

SwiftGraphQL generator comes as a CLI tool and as a library that you may import. You can use Mint, Homebrew and Make to use CLI only, or you may import it as a SPM dependency and use the generator itself.

#### Mint

```sh
mint install maticzav/swift-graphql
```

> You can read more about Mint [here](https://github.com/yonaskolb/mint).

#### Homebrew

```sh
brew tap maticzav/swift-graphql https://github.com/maticzav/swift-graphql.git
brew install SwiftGraphQL
```

#### Make

```sh
git clone https://github.com/maticzav/swift-graphql.git
cd swift-graphql
make install
```

To run the generator type `swift-graphql`. If you are using any custom scalars, you should create a configuration file called `swiftgraphql.yml` and put in data-type mappings as a key-value dictionary like this. Keys should be GraphQL types, and values should be SwiftGraphQL Codecs.

```yml
scalars:
  Date: DateTime
  Upload: Upload
```

You can also run `swift-graphql help` to learn more about options and how it works.

---

  <!-- index-start -->

- [Why?](#why)
- [How does it work?](#howdoesitwork)
- [Sending requests](#sendingrequests)
- [Reference](#reference)
  - [`send`](#send)
  - [`listen`](#listen)
  - [`Selection<Type, Scope>`](#selectiontypescope)
    - [Nullable, list, and non-nullable fields](#nullablelistandnonnullablefields)
    - [Making selection on the entire type](#makingselectionontheentiretype)
    - [Mapping Selection](#mappingselection)
  - [`Unions`](#unions)
  - [`Interfaces`](#interfaces)
  - [`OptionalArgument`](#optionalargument)
  - [`Codecs` - Custom Scalars](#codecscustomscalars)
  - [SwiftGraphQLCodegen](#swiftgraphqlcodegen)
    - [`generate`](#generate)
- [F.A.Q](#faq)
  - [How do I create a fragment?](#howdoicreateafragment)
  - [How do I create an alias?](#howdoicreateanalias)
  - [My queries include strange alias. What is that about?](#myqueriesincludestrangealiaswhatisthatabout)
  - [How do we populate the values?](#howdowepopulatethevalues)
  - [Why do I have to include try whenever I select something?](#whydoihavetoincludetrywheneveriselectsomething)
  - [What are the pitfalls in Apollo iOS that you were referring to at the top?](#whatarethepitfallsinapolloiosthatyouwerereferringtoatthetop)
- [Roadmap and Contributing](#roadmapandcontributing)
- [Thank you](#thankyou)
- [License](#license)
<!-- index-end -->

## Why?

**Why bother?** Simply put, it's going to save you and your team lots of time. There's a high chance that you are currently writing most of your GraphQL queries by hand. If not, there's probably some part of the link between backend and your frontend that you have to do manually. And as you well know, manual work is error-prone. This library is an end to end type-safe. This way, once your app compiles, you know it's going to work.

**Why another GraphQL library?** There was no other library that would let me fetch my schema, generate the Swift code, build queries in Swift, and easily adapt query results to my model. I was considering using Apollo iOS for my projects, but I couldn't get to the same level of type-safety as with SwiftGraphQL.

> This library has been heavily inspired by Dillon Kearns [elm-graphql](http://github.com/dillonkearns/elm-graphql).

---

## How does it work?

It seems like the best way to learn how to use SwiftGraphQL is by understanding how it works behind the scenes.

The first concept that you should know about is `Selection`. Selection lets you select which fields you want to query from a certain GraphQL object. The interesting part about Selection is that there's actually only one `Selection` type, but it has generic extensions. Those generic extensions are using _phantom types_ to differentiate which fields you may select in particular object.

TLDR; Phantom types let you use Generics to constrain methods to specific types. You can see them at work in the funny looking `Selection<Type, Scope>` parts of the code that let you select what you want to query. You can read more about phantom types [here](https://www.swiftbysundell.com/articles/phantom-types-in-swift/), but for now it suffice to understand that we use `Scope` to limit what you may or may not select in a query.

Now that you know about selection, let's say that we want to query some fields on our `Human` GraphQL type. The first parameter in `Selection` - `Type` - lets us say what the end "product" of this selection is going to be. This could be a `String`, a `Bool`, a `Human`, a `Droid` - anything. _You decide!_.

The second parameter - `Scope` (or `TypeLock`) - then tells `Selection` which object you want to query.

You can think of these two as:

- `Type`: what your app will receive
- `Scope` what SwiftGraphQL should query.

> Take a breath, pause, think about `TypeLock`, `Scope` and `Type`.

But how do we _select_ the fields?

That's what the `Selection` initializer is for. Selection initializer is a class with methods matching the names of GraphQL fields in your type. When you call a method two things happen. First, the method tells selection that you want to query that field. Secondly, it tries to process the data from the response and returns the data that was supposed to get from that particular field.

For example:

```swift
let human = Selection<Human, Objects.Human> { select in
    MyHuman(
        id: try select.id(), // String
        name: try select.name(), // String
        homePlanet: try select.homePlanet() // String?
    )
}
```

As you may have noticed, `id` returns just a string - not an optional. But how's that possible if the first time we call that function we don't even have the data yet? SwiftGraphQL intuitively mocks the data the first time around to make sure Swift is happy. That value, however, is left unnoticed - you'll never see it.

> Take a breath, `Selection` is quite neat, right?

To make selection even easier, library makes typealiaii for each type in your schema. This way you don't have to write that much boilerplate and we can leverage Swift type-system to figure out some things for us. You can rewrite the above selection like this.

```swift
let human = Selection.Human { select in
    MyHuman(
        id: try select.id(), // String
        name: try select.name(), // String
        homePlanet: try select.homePlanet() // String?
    )
}
```

Alright! Now that we truly understand `Selection`, let's fetch some data. We use `GraphQLClient`'s `send` method to send queries to the backend. To make sure you are sending the right data, `send` methods only accept selections of `Operations.Query` and `Operations.Mutation`. This way, compiler will tell you if you messed something up.

We construct a query in a very similar fashion to making a human selection.

```swift
let query = Selection.Query {
    try $0.humans(human.list)
}
```

The different part now is that `humans` accept another selection - a human selection. Furthermore, each selection let's you make it nullable using `.nullable` or convert it into a list using `.list`. This way, you can query a list of humans or an optional human.

_NOTE:_ We could also simply count the number of humans in the database. We would do that by changing the `Type` to `Int` - we are counting - and use Swift's `count` property on a list.

```swift
let query = Selection.Query {
    try $0.humans(human.list).count
}
```

> Take a breath. This is it. Pretty neat, huh?! 😄

## Sending requests

Once you've created a query-, mutation- or a subscription-type selection, you may call one of the `send` and `listen` methods that SwiftGrpahQL exposes. To fetch a query or send a mutation, use `send` method. And to listen for subscriptions, use `listen` method.

> Make sure you use `ws` protocol when listening for subscriptions!

```swift
send(query, to: "http://localhost:4000") { result in
    if let data = try? result.get() {
        print(data)
    }
}

listen(for: subscription, on: "ws://localhost:4000/graphql") { result in
    if let data = try? result.get() {
        print(data)
    }
}
```

> 💡 If you try to pass in any other type instead of root operation types, your code won't compile.

---

## Reference

### `send`

- `SwiftGraphQL`

SwiftGraphQL exposes only two methods - `send` - that lets you send your query to your server and `listen` that lets you create subscription listeners. It uses URLRequest internally and shared URLSession to perform the request, and returns Swift's Request type with the data.

You can pass in the dictionary of `headers` to implement authorization mechanism.

```swift
send(query, to: "http://localhost:4000") { result in
    if let data = try? result.get() {
        print(data)
    }
}
```

### `listen`

- `SwiftGraphQL`

Lets you listen for subscription events coming from your server.
You can pass in the dictionary of `headers` to implement authorization mechanism.

```swift
listen(for: subscription, on: "ws://localhost:4000/graphql") { result in
    if let data = try? result.get() {
        print(data)
    }
}
```

> SwiftGraphQL intentionally doesn't implement any caching mechanism. This is only a query library and it does that very well. You should implement caching functionality yourself, but you probably don't need it in most cases.

### `Selection<Type, Scope>`

- `SwiftGraphQL`

Selection lets you select fields that you want to fetch from the query on a particular type.

SwiftGraphQL has generated phantom types for your operations, objects, interfaces and unions. You can find them by typing `Unions.`/`Interfaces.`/`Objects.`/`Operations.` followed by a name from your GraphQL schema. You plug those into the `Scope` parameter.

The other parameter `Type` is what your constructor should return.

> We generate type alias in selection which let you use XCode intellisnse and may infer your return type. They work like `Selection.ObjectName`.

##### Nullable, list, and non-nullable fields

Selection packs a collection of utility functions that let you select nullable and list fields using your existing selecitons.
Each selection comes with three calculated properties that let you do that:

- `list` - to query lists
- `nullable` - to query nullable fields
- `nonNullOrFail` - to query nullable fields that should be there

```swift
// Create a non-nullable selection.
let human = Selection.Human {
    Human(
        id: try $0.id(),
        name: try $0.name()
    )
}

// Use it with nullable and list fields.
let query = Selection.Query {
    let list = try $0.humans(human.list)
    let nullable = try $0.human(id: "100", human.nullable)
}
```

You can achieve the same effect using `Selection` static functions `.list`, `.nullable`, and `.nonNullOrFail`.

```swift
// Use it with nullable and list fields.
let query = Selection.Query {
    let list = try $0.humans(Selection.list(human))
}
```

##### Making selection on the entire type

You might want to write a selection on the entire type from the selection composer itself. This usually happens if you have a distinct identifier reused in many types.

Consider the following scenario where we have an `id` field in `Human` type. There are many cases where we only query `id` field from the `Human` that's why we create a human id selection.

```swift
let humanId = Selection<HumanID, Objects.Human> {
    HumanID.fromString(try $0.id())
}
```

Now, we want to reuse that same selection when query a detailed human type. To do that, we can use `selection` helper method that lets you make a selection on the whole `TypeLock` from inside the selection.

```swift
struct Human {
    let id: HumanID
    let name: String
}

let human = Selection.Human {
    Human(
        id: try $0.selection(humanId),
        name: try $0.name()
    )
}
```

An alternative approach would be to manually rewrite the selection inside `Human` again.

```swift
let human = Selection.Human {
    Human(
        id: HumanID.fromString(try $0.id()),
        name: try $0.name()
    )
}
```

Having distinct types for ids of different object types is particularly useful in large projects as it gives you verification that you are not using a wrong identifier for a particular type of field. At first, this might seem useless and cumbersome, but it makes your code more robust once you get used to it.

##### Mapping Selection

You might want to map the result of your selection to a new type and get a selection for that new type.
You can do that by calling a `map` function on selection and provide a mapping.

```swift
struct Human {
    let id: String
    let name: String
}

// Create a selection.
let human = Selection<Human, Objects.Human> {
    Human(
        id: try $0.id(),
        name: try $0.name(),
    )
}

// Map the original selection on Human to return String.
let humanName: Selection<String, Objects.Human> = human.map { $0.name }
```

> ⚠️ Don't make any nested calls to the API. Use the first half of the initializer to fetch all the data and return the calculated result. Just don't make nested requests.

```swift
// WRONG!
let human = Selection<String, Objects.Human> { select in
    let message: String
    if try select.likesStrawberries() {
        message = try select.name()
    } else {
        message = try select.homePlanet()
    }
    return message
}

// Correct.
let human = Selection<String, Objects.Human> { select in

    /* Data */
    let likesStrawberries = try select.likesStrawberries()
    let name = try select.name()
    let homePlanet = try select.homePlanet()

    /* Return */
    let message: String
    if likesStrawberries {
        message = name
    } else {
        message = homePlanet
    }
    return message
}
```

### `Unions`

- `SwiftGraphQL`

When fetching a union you should provide selections for each of the union sub-types. Additionally, all of those selections should resolve to the same type.

```swift
let characterUnion = Selection<String, Unions.CharacterUnion> {
    try $0.on(
        human: .init { try $0.funFact() /* String */ },
        droid: .init { try $0.primaryFunction() /* String */ }
    )
}
```

You'd usually want to create a Swift enumerator and have different selecitons return different cases.

### `Interfaces`

- `SwiftGraphQL`

Interfaces are very similar to unions. The only difference is that you may query for a common field from the intersection.

```swift
let characterInteface = Selection<String, Interfaces.Character> {

    /* Common */
    let name = try $0.name()

    /* Fragments */
    let about = try $0.on(
        droid: Selection<String, Objects.Droid> { droid in try droid.primaryFunction() /* String */ },
        human: Selection<String, Objects.Human> { human in try human.homePlanet() /* String */ }
    )

    return "\(name). \(about)"
}
```

You'd usually want to create a Swift enumerator and have different selecitons return different cases.

### `OptionalArgument`

- `SwiftGraphQL`

GraphQL's `null` value in an input type may be entirely omitted to represent the absence of a value or supplied as `null` to provide `null` value. This comes in especially handy in mutations.

Because of that, every input object that has an optional property accepts an optional argument that may either be `.present(value)`, `.absent()` or `.null()`. We use functions to support recursive type annotations that GraphQL allows.

> NOTE: Every nullable argument is by default absent so you don't have to write boilerplate.

### `Codecs` - Custom Scalars

- `SwiftGraphQL`

SwiftGraphQL lets you implement custom scalars that your schema uses. You can do that by conforming to the `Codec` protocol. It doesn't matter where you implement the codec, it should only be visible to the API so that your app compiles.

```swift
public protocol Codec: Codable & Hashable {
    associatedtype WrappedType
    static var mockValue: WrappedType { get }
}
```

You should provide a codec for every scalar that is not natively supported by GraphQL, or map it to an existing Swift type. You can read more about scalar mappings below, in the generator section of the documentation.

```swift
// DateTime Example
struct DateTime: Codec {
    private var data: Date

    init(from date: Date) {
        self.data = date
    }

    // MARK: - Public interface

    var value: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr")
        formatter.setLocalizedDateFormatFromTemplate("dd-MM-yyyy")

        return formatter.string(from: self.data)
    }

    // MARK: - Codec conformance

    // MARK: - Decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)

        self.data = Date(timeIntervalSince1970: TimeInterval(value))
    }

    // MARK: - Encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Int(data.timeIntervalSince1970))
    }

    // MARK: - Mock value
    static var mockValue = DateTime(from: Date())
}
```

> Don't forget to add your scalar mapping to code generator options. Otherwise, generator will fail with _unknown scalar_ error.

### SwiftGraphQLCodegen

SwiftGraphQLCodegen exposes only one function - `generate` - that lets you fetch schema from a remote endpoint and get Swift code that SwiftGraphQL relies on to create queries.

#### `generate`

- `SwiftGraphQLCodegen`

Lets you generate the code based on a remote schema.

> I suggest you try to do most of the things with built-in CLI and only opt-in for the codegen when absolutely necessary.

```swift
let scalars: [String: String] = ["Date": "DateTime"]
let generator = GraphQLCodegen(scalars: config.scalars)

let code = try generator.generate(from: url)
```

---

## F.A.Q

### How do I create a fragment?

Just create a new variable with a selection. In a way, every selection is a fragment!

### How do I create an alias?

You can't. SwiftGraphQL aims to use Swift's high level language features in favour of GraphQL. The primary goal of GraphQL alias is to support fetching same fields with different parameters. SwiftGraphQL automatically manages alias based on the values you provide to a particular field. Because of this, you can select the same field as many times as you'd like.

### My queries include strange alias. What is that about?

SwiftGraphQL uses hashes to construct your queries. There are two parts of the query builder that contribute to the hashes;

- the first one - _query parameters_ - uses hashes to differentiate between same fields with different parameters. Because of this, you don't have to manually check that your field names don't collide.
- the second one - _query variables_ - uses hashes to link your input values to the part of the query they belong to. SwiftGraphQL laverages Swift's native JSON serialization as I've found it incredibly difficult to represent enumerator values in GraphQL SDL. This way it's also more performant.

```gql
query(
  $__rsdpxy7uqurl: Greeting!
  $__l9q38fwdev22: Greeting!
  $_b2ryvzutf9x2: ID!
) {
  greeting__m9oi5wy5dzot: greeting(input: $__rsdpxy7uqurl)
  character__16agce2xby25o: character(id: $_b2ryvzutf9x2) {
    __typename
    ... on Human {
      homePlanet___5osgbeo0g455: homePlanet
    }
    ... on Droid {
      primaryFunction___5osgbeo0g455: primaryFunction
    }
  }
}
```

### How do we populate the values?

We use the limitation of Swift's types that you cannot recursively reference a nullable type, but can reference a list type. To prevent cycles in value mocking, we always return empty lists and fill all scalars and referenced objects with values. If you were to create a cycle, Swift wouldn't let you compile your app.

### Why do I have to include try whenever I select something?

Swift handles errors in a very upfront way. Since we are trying to decode nested values, the decoder might fail
at various different depths. Because of that, we have to write `try`.

### What are the pitfalls in Apollo iOS that you were referring to at the top?

Apollo iOS code generator lets you write your queries upfront and generates the type annotations for them. Let's say that there's a `Human` object type that has a property `friends` (who are also humans). Because you could select different fields in `Human` than in `friends` (sub-`Human`), Apollo generates two different nested structs for "each" of the humans. In TypeScript and JavaScript this is not a problem, since objects are not "locked" into definition. In Swift, however, this becomes problematic as you probably want to represent all your humans in your model with only one human type.

I ended up writing lots of boilerplate just to get it working, and would have to rewrite it in multiple places everytime backend team changed something.

## Roadmap and Contributing

This library is feature complete for our use case. We are actively using it in our production applications and plan to expand it as our needs change. We'll also publish performance updates and bug fixes that we find.

I plan to actively maintain it for many upcoming years. Swift seems like a fantastic language and I've only started learning it.

Feel free to create a pull request with future improvements. Please, document your contributions well, and clearly outline the benefits of the change. It's also very helpful to include the ideas behind changes.

Here's a rough collection of ideas we might tackle next:

- Networking Layer
- Caching

> PS.: PRs for the above features will be reviewed a lot more quickly!

## Thank you

I want to dedicate this last secion to everyone who helped me along the way.

- First, I would like to thank Dillon Kearns, the author of [elm-graphql](http://github.com/dillonkearns/elm-graphql), who inspired me to write the library, and helped me understand the core principles behind his Elm version.
- I would like to thank Peter Albert for giving me a chance to build this library, having faith that it's possible, and all the conversations that helped me push through the difficult parts of it.
- Lastly, I'd like to thank Martijn Walraven and Apollo iOS team, who helped me understand how Apollo GraphQL works, and for the inspiration about the parts of the code I wasn't sure about.

Thank you! 🙌

---

## License

MIT @ Matic Zavadlal
