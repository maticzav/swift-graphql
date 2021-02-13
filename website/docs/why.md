---
id: why
title: Why Kayu?
sidebar_label: Why Kayu
---

### Design decisions behind Kayu

I want to list here some of the distinct choices that Kayu makes and the decision process behind them.

#### Our goals

We want:

- **KayuJS to be the best way to consume GraphQL APIs.** Primarily, we want to focus on server side interactions and have a good frontend support as a result.

#### Why functions in selection?

Kayu was heavily inspired by `elm-graphql` and `swift-graphql` libraries. Because both, Elm and TypeScript, are statically typed and don't allow for easy object-type inference like TypeScript does, they rely on functions to turn bits of data into a final structure.

We don't need that in TypeScript. The reason we kept it that way is that it is usually a good practice to map your schema into an internal representation - a model. Having a function in the selection allows you to create a class, filter results, you name it. All while making a selection for your field.

#### Alternatives

A lot of existing projects that focus on code generation

- https://github.com/gqless/gqless
- https://github.com/timkendall/tql
- https://github.com/dotansimha/graphql-code-generator
