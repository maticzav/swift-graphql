import { YogaInitialContext } from '@graphql-yoga/node'
import { PrismaClient } from '@prisma/client'

import { AuthSessions } from './auth'
import { Mailbox } from './mailbox'
import { PubSub } from './pubsub'

export interface Context extends YogaInitialContext {
  /**
   * Authentication sessions that are currently active.
   */
  sessions: AuthSessions

  /**
   * Shared PubSub instance for message broadcasting.
   */
  pubsub: PubSub

  /**
   * Shared access to the database.
   */
  prisma: PrismaClient

  /**
   * Count of messages that each user hasn't read yet.
   */
  mailbox: Mailbox

  /**
   * Currently authenticated user and its basic information.
   */
  user: { id: string } | null
}
