---
id: installation
title: Installation
sidebar_label: Installation
---

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

Kayu to regenerates the API on every subsequent install. Manually, you can trigger the generation by running `yarn kayu`.
