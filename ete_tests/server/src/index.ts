import { makeSchema } from '@nexus/schema'
import { ApolloServer } from 'apollo-server'
import * as path from 'path'

import { data } from './data'
import * as allTypes from './graphql'
import { ContextType } from './types/backingTypes'

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
  context: ({ req }) => {
    /* Context */
    let context: ContextType = {
      req: req,
      data: data,
    }
    return context
  },
  plugins: [
    {
      requestDidStart(requestContext) {
        console.log('Request started! Query:\n' + requestContext.request.query)
        console.log(requestContext.request.variables)

        return {}
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
