import { createPubSub } from '@graphql-yoga/node'
import type { Comment } from '@prisma/client'

/**
 * PubSub instance shared by the server/
 */
export const pubsub = createPubSub<{
  MESSAGE: [payload: Comment]
}>({})

export type PubSub = typeof pubsub
