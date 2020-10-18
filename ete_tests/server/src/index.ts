import { makeSchema, nullabilityGuardPlugin } from '@nexus/schema'
import { ApolloServer } from 'apollo-server'
import * as path from 'path'

import * as allTypes from './graphql'

/* Schema */

const schema = makeSchema({
  types: allTypes,
  outputs: {
    schema: path.join(__dirname, '../star-wars-schema.graphql'),
    typegen: path.join(
      __dirname.replace(/\/dist$/, '/src'),
      './star-wars-typegen.ts',
    ),
  },
  plugins: [
    nullabilityGuardPlugin({
      shouldGuard: true,
      fallbackValues: {
        String: () => '',
        ID: () => 'MISSING_ID',
        Boolean: () => true,
      },
    }),
  ],
  typegenAutoConfig: {
    sources: [
      {
        source: path.join(
          __dirname.replace(/\/dist$/, '/src'),
          './types/backingTypes.ts',
        ),
        alias: 'swapi',
      },
    ],
    contextType: 'swapi.ContextType',
  },
  prettierConfig: require.resolve('../prettier.config.js'),
})

/* Server */

const server = new ApolloServer({
  schema,
})

const port = process.env.PORT || 4000

server.listen({ port }, () => {
  console.log(
    `🚀 Server ready at http://localhost:${port}${server.graphqlPath}`,
  )
})
