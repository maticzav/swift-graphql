import { createPubSub } from '@graphql-yoga/node'

/**
 * PubSub instance shared by all resolvers
 */
export const pubsub = createPubSub<{
  mailbox: [userId: string, payload: { count: number }]
}>({})

export type PubSub = typeof pubsub
