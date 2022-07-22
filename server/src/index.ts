import { createServer, YogaInitialContext } from '@graphql-yoga/node'
import { renderGraphiQL } from '@graphql-yoga/render-graphiql'
import { makeExecutableSchema } from '@graphql-tools/schema'

import { Server as WebSocketServer } from 'ws'
import { useServer } from 'graphql-ws/lib/use/ws'

import * as fs from 'fs'
import * as path from 'path'

import { resolvers } from './resolvers'
import { getUserName } from './lib/auth'
import { Context } from './lib/context'

// Server

const typeDefs = fs.readFileSync(path.resolve(__dirname, './schema.graphql')).toString('utf-8')

async function main() {
  const server = createServer<Context, any>({
    hostname: '0.0.0.0',
    schema: makeExecutableSchema({
      typeDefs,
      resolvers,
      resolverValidationOptions: {
        requireResolversToMatchSchema: 'error',
      },
    }),
    renderGraphiQL,
    graphiql: {
      subscriptionsProtocol: 'WS',
    },
    logging: true,
    maskedErrors: false,
    context: async (ctx: YogaInitialContext): Promise<Context> => {
      let user: { name: string } | null = null

      const name = getUserName(ctx)
      if (name) {
        user = { name }
      }

      return { ...ctx, user }
    },
  })

  // Get NodeJS Server from Yoga
  const httpServer = await server.start()

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
      onConnect(ctx) {
        console.log('connection created')
        console.log({ ctx })

        ctx.extra.socket.on('message', (data) => {
          console.log(String(data))
        })
      },
      onDisconnect(ctx) {
        console.log('connection disconnected')
        console.log({ ctx })
      },
      onClose(ctx) {
        console.log('connection closed')
        console.log({ ctx })
      },
      onOperation(ctx) {
        console.log('operation started')
        console.log({ ctx })
      },
      onComplete(ctx) {
        console.log('operation completed')
        console.log({ ctx })
      },
      onNext(ctx) {
        console.log('operation next')
        console.log({ ctx })
      },
      connectionInitWaitTimeout: 5000,
      onError(ctx, message) {
        console.log('error in connection')
        console.log({ ctx })
        console.log(message)
      },
      onSubscribe: async (ctx, msg) => {
        console.log('received subscription request')
        console.log({ ctx })
        console.log({ msg })

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
        if (errors.length) return errors
        return args
      },
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
