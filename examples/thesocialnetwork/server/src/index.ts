import { createServer, YogaInitialContext } from '@graphql-yoga/node'
import { renderGraphiQL } from '@graphql-yoga/render-graphiql'
import { makeExecutableSchema } from '@graphql-tools/schema'
import { PrismaClient } from '@prisma/client'

import * as fs from 'fs'
import * as path from 'path'

import { Server as HTTPServer } from 'http'
import { Server as WebSocketServer } from 'ws'
import { useServer } from 'graphql-ws/lib/use/ws'

import { AuthSessions } from './lib/auth'
import { Context } from './lib/context'
import { pubsub } from './lib/pubsub'
import { resolvers } from './resolvers'
import { Mailbox } from './lib/mailbox'

// Server

const typeDefs = fs.readFileSync(path.resolve(__dirname, './schema.graphql')).toString('utf-8')

async function main() {
  const sessions = new AuthSessions()
  const prisma = new PrismaClient()
  const mailbox = new Mailbox()

  const server = createServer<Context, any>({
    hostname: '0.0.0.0',
    schema: makeExecutableSchema({
      typeDefs,
      resolvers,
      resolverValidationOptions: {
        requireResolversToMatchSchema: 'error',
      },
    }),
    graphiql: {
      subscriptionsProtocol: 'WS',
    },
    renderGraphiQL,
    logging: true,
    maskedErrors: false,
    context: async (ctx: YogaInitialContext): Promise<Context> => {
      let user: { id: string } | null = null

      const id = sessions.getUserIdFromContext(ctx)
      if (id) {
        user = { id }
      }

      return {
        ...ctx,

        prisma,
        pubsub,
        sessions,
        mailbox,

        user,
      }
    },
  })

  // Get NodeJS Server from Yoga
  const httpServer: HTTPServer = await server.start()

  // Create WebSocket server instance from our Node server
  const wsServer = new WebSocketServer({
    server: httpServer,
    path: server.getAddressInfo().endpoint,
  })

  // Integrate Yoga's Envelop instance and NodeJS server with graphql-ws
  useServer(
    {
      execute: (args: any) => args.rootValue.execute(args),
      subscribe: (args: any) => args.rootValue.subscribe(args),

      onSubscribe: async (ctx, msg) => {
        const { schema, execute, subscribe, contextFactory, parse, validate } = server.getEnveloped(ctx)

        const args = {
          schema,
          operationName: msg.payload.operationName,
          document: parse(msg.payload.query),
          variableValues: msg.payload.variables,
          contextValue: await contextFactory(),
          rootValue: {
            execute,
            subscribe,
          },
        }

        const errors = validate(args.schema, args.document)
        if (errors.length) {
          return errors
        }

        return args
      },

      connectionInitWaitTimeout: 5000,
    },
    wsServer,
  )
}

// Start

if (require.main === module) {
  main().catch((err) => {
    console.error(err)
  })
}
