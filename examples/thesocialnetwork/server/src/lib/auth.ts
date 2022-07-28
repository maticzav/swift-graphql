import { YogaInitialContext } from '@graphql-yoga/node'

import { generateAlphaNumericString } from './random'

export class AuthSessions {
  private sessions: { [key: string]: string } = {}

  constructor() {}

  /**
   * Returns a user id if there's a session associated with a given user.
   */
  public getUserIdFromContext(ctx: YogaInitialContext): string | null {
    const header = ctx.request?.headers?.get('Authentication')

    if (!header) {
      return null
    }

    const token = header.toLowerCase().replace('bearer ', '')
    return this.sessions[token] || null
  }

  /**
   * Associates user with a random session identifier.
   */
  public createSessionForUser(userId: string): string {
    const token = generateAlphaNumericString(16)
    this.sessions[token] = userId

    return token
  }
}

/**
 * Error that we may use to present an unauthenticated state.
 */
export class AuthError extends Error {
  constructor() {
    super('Not authorized')
  }
}
