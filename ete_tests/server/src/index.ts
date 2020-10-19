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
  nonNullDefaults: {
    input: true,
    output: true,
  },
  plugins: [],
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
  debug: true,
  plugins: [
    {
      // Fires whenever a GraphQL request is received from a client.
      requestDidStart(requestContext) {
        console.log('Request started! Query:\n' + requestContext.request.query)

        return {
          willSendResponse(context) {
            console.log(context.errors)
          },
        }
      },
    },
  ],
})

const port = process.env.PORT || 4000

server.listen({ port }, () => {
  console.log(
    `🚀 Server ready at http://localhost:${port}${server.graphqlPath}`,
  )
})
