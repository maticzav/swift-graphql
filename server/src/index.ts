import { createServer, useExtendContext } from '@graphql-yoga/node'
import { makeExecutableSchema } from '@graphql-tools/schema'

import { typeDefs } from './schema'
import { resolvers } from './resolvers'

import { Context } from './lib/sources'
import { pubsub } from './lib/pubsub'
import { prisma } from './lib/prisma'

// Server

const server = createServer<Context, any>({
  schema: makeExecutableSchema({
    typeDefs,
    resolvers,
    resolverValidationOptions: {
      requireResolversToMatchSchema: 'error',
    },
  }),
  logging: true,
  maskedErrors: true,
  plugins: [useExtendContext(() => ({ pubsub, prisma }))],
})

// Start

if (require.main === module) {
  server
    .start()
    .then(() => {})
    .catch((err) => {
      console.error(err)
    })
}
