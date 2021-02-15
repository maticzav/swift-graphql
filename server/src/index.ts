import { makeSchema } from 'nexus'
import { ApolloServer } from 'apollo-server'
import * as path from 'path'

import { data } from './data'
import * as allTypes from './graphql'
import { ContextType } from './types/backingTypes'

/* Schema */

const schema = makeSchema({
  types: allTypes,
  nonNullDefaults: {
    input: true,
    output: true,
  },
  outputs: {
    typegen: path.join(__dirname, 'nexus.types.ts'),
    schema: path.join(__dirname, './schema.graphql'),
  },
  sourceTypes: {
    modules: [
      {
        module: path.join(
          __dirname.replace(/\/dist$/, '/src'),
          './types/backingTypes.ts',
        ),
        alias: 'swapi',
      },
    ],
  },
  contextType: {
    module: path.join(
      __dirname.replace(/\/dist$/, '/src'),
      './types/backingTypes.ts',
    ),
    export: 'ContextType',
  },
  prettierConfig: require.resolve('../../prettier.config.js'),
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
    /**
     * Logs the query to the console.
     */
    {
      requestDidStart(requestContext) {
        console.log(requestContext.request.query)
        return {
          willSendResponse(res) {
            console.log(res.response.data)
          },
        }
      },
    },
  ],
})

/* Start */

if (require.main === module) {
  const port = process.env.PORT || 4000

  server.listen({ port }, () => {
    console.log(
      `🚀 Server ready at http://localhost:${port}${server.graphqlPath}`,
    )
  })
}
