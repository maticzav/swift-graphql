import { makeSchema } from '@nexus/schema'
import { ApolloServer } from 'apollo-server'
import * as path from 'path'
import * as fs from 'fs'

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
    /**
     * Logs the query to the console.
     */
    {
      requestDidStart(requestContext) {
        console.log(requestContext.request.query)
        return {}
      },
    },
    /**
     * Saves responses for debuging purposes.
     */
    {
      requestDidStart(ctx) {
        const operation = ctx.request.operationName

        if (!operation) return {}

        console.log(`Incoming request ${operation}`)

        const filename = `${operation}.json`
        const filepath = path.resolve(__dirname, '../responses', filename)

        return {
          willSendResponse(resp) {
            // Save the response to a file.

            try {
              const data = JSON.stringify(resp.response, null, 2)
              fs.writeFileSync(filepath, data)
            } catch (err) {
              console.log(err)
            }

            return resp
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
