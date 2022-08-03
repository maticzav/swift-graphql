import { DateTimeResolver } from 'graphql-scalars'
import { DateTime } from 'luxon'

import { AuthError, getToken } from './lib/auth'
import { Context } from './lib/context'

import { Resolvers } from './types'

export const resolvers: Resolvers<Context> = {
  // Scalars
  DateTime: DateTimeResolver,

  // Root Resolvers
  Query: {
    hello: (parent, args, ctx) => 'Hello world!',
    date: (parent, args, ctx) => DateTime.local().toJSDate(),
    list: (parent, args, ctx) => ['a', 'b', 'c'],
    oneOf: (parent, args, ctx) => args.option,
    secret: (parent, args, ctx) => {
      if (!ctx.user) {
        return null
      }

      return 'secret'
    },
  },
  Mutation: {
    form: async (parent, args, ctx) => {
      if (args.params.master) {
        return {
          __typename: 'Padawan',
          name: args.params.name,
          master: { name: args.params.master, age: args.params.age },
        }
      }

      return {
        __typename: 'Master',
        name: args.params.name,
        age: args.params.age,
      }
    },
    login: async (parent, args, ctx) => {
      if (args.name.length < 3) {
        return {
          __typename: 'AuthPayloadFailure',
          message: 'Name too short!',
        }
      }

      return {
        __typename: 'AuthPayloadSuccess',
        name: args.name,
        token: getToken(args.name),
      }
    },
  },
  Subscription: {
    count: {
      // This will return the value on every 1 sec until it reaches 0
      subscribe: async function* (_, { from, to }) {
        const direction = from > to ? -1 : 1
        for (let i = from; i != to; i += direction) {
          await new Promise((resolve) => setTimeout(resolve, 500))
          yield { count: i }
        }
      },
    },
    secret: {
      // This will return the value on every 1 sec until it reaches 0
      subscribe: async function* (_, { from }, ctx) {
        if (!ctx.user) {
          throw new AuthError()
        }

        for (let i = from; i >= 0; i -= 2) {
          await new Promise((resolve) => setTimeout(resolve, 500))
          yield { secret: i }
        }
      },
    },
  },

  // Types
}
