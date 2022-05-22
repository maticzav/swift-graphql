import { YogaInitialContext } from '@graphql-yoga/node'
import * as jwt from 'jsonwebtoken'

const SECRET = 'sshhh'

/**
 * Returns an autohrization token if the user is authenticated.
 */
export function getUserName(ctx: YogaInitialContext): string | null {
  const authHeader = ctx.request?.headers?.get('Authentication')
  if (authHeader) {
    const token = authHeader.replace('Bearer ', '')
    const decoded = jwt.verify(token, SECRET) as { user: string } | undefined

    if (decoded) {
      return decoded.user
    }
  }

  return null
}

/**
 * Creates authentication token from user's ID.
 */
export function getToken(user: string): string {
  return jwt.sign({ user }, SECRET)
}

/**
 * Error that we may use to present an unauthenticated state.
 */
export class AuthError extends Error {
  constructor() {
    super('Not authorized')
  }
}
