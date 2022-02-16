import { YogaInitialContext } from '@graphql-yoga/node'
import { PrismaClient } from '@prisma/client'

import { PubSub } from './pubsub'

export interface Context extends YogaInitialContext {
  pubsub: PubSub
  prisma: PrismaClient
}
