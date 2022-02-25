import { YogaInitialContext } from '@graphql-yoga/node'
import * as jwt from 'jsonwebtoken'

const SECRET = process.env.APP_SECRET ?? 'sshhh'

/**
 * Returns an autohrization token if the user is authenticated.
 */
export function getUserId(ctx: YogaInitialContext): string | null {
  const Authorization = ctx.request.headers.get('Authorization')
  if (Authorization) {
    const token = Authorization.replace('Bearer ', '')
    const decoded = jwt.verify(token, SECRET) as
      | {
          userId: string
        }
      | undefined

    if (decoded) {
      return decoded.userId
    }
  }

  return null
}

/**
 * Creates authentication token from user's ID.
 */
export function getToken(user: string): string {
  return jwt.sign({ userId: user }, SECRET)
}

/**
 * Error that we may use to present an unauthenticated state.
 */
export class AuthError extends Error {
  constructor() {
    super('Not authorized')
  }
}