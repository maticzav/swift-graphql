import { DateTimeResolver } from 'graphql-scalars'
import { IResolvers } from '@graphql-tools/utils'

import { Context } from './lib/sources'

export const resolvers: IResolvers<{}, Context> = {
  // Scalars
  DateTime: DateTimeResolver,
  // Resolvers
  Query: {
    hello: (parent, args, ctx) => 'Hello world!',
  },
  Mutation: {},
  Subscription: {},
}
