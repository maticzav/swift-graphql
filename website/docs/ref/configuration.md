---
id: config
title: Configuring KayuJS
sidebar_label: Configuration
---

To configure Kayu, create a `kayu.config.js` file next to your project's `package.json`.

```ts
module.exports = {
  endpoint: 'https://yourgraphql.com', // your API endpoint
  api: './src/api.ts', // path to generated file
  schema: './schema.json', // path to cache
}
```

## Schema Endpoint

Kayu may load your schema from `schema.graphql` or from your GraphQL server endpoint. When using URL as an endpoint, make sure you point it to your GraphQL server url, not (just) the root of your server.

When loading your schema from local `schema.graphql` file, make sure that path to that file is relative to the configuration.

## Other Options

Here's a list of parameters that Kayu accepts in its configuration.

```ts
export type Config = {
  endpoint: string
  /**
   * Path to output file relative to this file.
   */
  api: string
  /**
   * Path to codecs declaration relative to this file.
   */
  codecs?: string
  /**
   * Path to schema cache relative to this file.
   */
  schema: string
  /**
   * Optional path to prettier.config.js path relative to this file.
   * We use it to format the generated API.
   */
  prettier?: string
}
```

Trigger API generation by running `yarn kayu`.
