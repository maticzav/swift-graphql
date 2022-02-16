import { PrismaClient } from '@prisma/client'
import * as qs from 'query-string'

// We use a "global" PrismaClient instance to make sure we don't
// create multiple instances of the client and pollute the connection pool.
let client: PrismaClient | null = null

/**
 * Your database connection.
 */
export const prisma = (): PrismaClient => {
  if (client === null) {
    // We manually set the connection_limit to avoid congestion.
    const { url, query } = qs.parseUrl(process.env.DATABASE_URL!)
    const normalizedURL = qs.stringifyUrl({
      url,
      query: {
        connection_limit: 30,
        ...query,
      },
    })

    client = new PrismaClient({
      datasources: {
        db: { url: normalizedURL },
      },
    })
  }

  return client
}
