import { createPubSub } from '@graphql-yoga/node'

/**
 * PubSub instance shared by the server/
 */
export const pubsub = createPubSub({})

export type PubSub = typeof pubsub
