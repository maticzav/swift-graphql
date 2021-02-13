---
id: quick_start
title: Quick Start
sidebar_label: Quick Start
---

## Installation

Create a configuration file in the root of your project (next to your package.json) called `kayu.config.js`.
Here are the three parameters that Kayu needs in order to work as expected.

```ts
module.exports = {
  endpoint: 'https://yourgraphql.com', // your API endpoint
  api: './src/api.ts', // path to generated file
  schema: './schema.json', // path to cache
}
```

Now install Kayu using package manager of your choice.

```bash
yarn install @kayu/client
```

Kayu, will try to guess the root of your project and check for a configuraiton there. If it doesn't exist yet, it'll scaffold one for you.

Kayu regenerates the API on every subsequent install. Manually, you can trigger the generation by running `yarn kayu`.

## Writing Queries

The generated code contains a variable for each of the types your schema exports. There's `objects`, `interfaces`, `unions` and, of course, `send` that lets us execute the query.

To create a query, start by writing the type, followed by a name. Then, call it! It's a function that accepts another function and gives you a _bag_ (`t`) of things that you can select in that object.

```ts
const query = objects.query((t) => {
  // here we'll make a selection
})
```

To select a particular field, start by typing `t`. Your IDE will probably hint you all the fields that you may query on that object. To query a particular field, call it as a function.

```ts
const query = objects.query((t) => {
  // Selection
  let hello = t.hello()
})
```

Now that we've made a selection, we also want to use that value. How do we do that? We simply return it!

```ts
const query = objects.query((t) => {
  // Selection
  let hello = t.hello()
  return hello
})
```

## Type Selection

When writing a query, we usually want to fetch some subfields of a certain type. To explain how we do that, we'll make up a schema and see how we put the pieces together.

```gql
type Human {
  id: ID!
  name: String
}

type Query {
  people: [Human!]!
}
```

Now we want to query all people from our schema, and we want to query their names. We first make a `human` selection and pass it to `query`. Since it's a list type, we have to use the modifier `.list` to correctly decode the response.

```ts
const human = objects.human((t) => t.name())

const query = objects.query((t) => {
  let people = t.people(human)
  return people
})
```

Know that Kayu will complain if you provide a wrong type to a certin seleciton. Remember, if your project compiles, your queries work!

## Arguments

Some fields take arguments - these will come as a first parameter of your function. Let's extend the above schema.

```gql
type Human {
  id: ID!
  name: String
}

type Query {
  people(name: String!): [Human!]!
}
```

To search all people whose names begin with "Kay", we'd write the following query.

```ts
import { o } from './api.ts'

const search = 'Kay'

const query = o.query((t) => {
  // Make an inline selection, and add arguments.
  let people = t.people({ name: search })(o.human((h) => h.name()))
  return people
})
```

We generate argument part of the function only when field requires arguments.

## Next Steps

We are confident that you know enough to start making queries using Kayu.
Though if you want to learn more, check out these links.

- [SelectionSets](/docs/guide/selection)
- [Going Crazy with Kayu](/docs/guide/crazy)
- [Custom Scalars](/docs/guide/codecs)
