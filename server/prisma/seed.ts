import { PrismaClient } from '@prisma/client'
import crypto from 'crypto'
import fetch from 'node-fetch'
import qs from 'query-string'

const CONFIG = {
  pubKey: process.env.MARVEL_PUBLIC_KEY!,
  privateKey: process.env.MARVEL_PRIVATE_KEY!,
}

const prisma = new PrismaClient()

async function main() {
  console.log({ CONFIG })

  // Data from the Marvel API

  const characters = await api('characters', { limit: 50 })

  console.log(characters.data.results)
}

// Start

if (require.main === module) {
  main()
}

// Utils ---------------------------------------------------------------------

// https://developer.marvel.com/documentation/apiresults
type APIResponse<T> = {
  /**
   * The HTTP status code of the returned result.
   */
  code: number
  status: 'Ok' | 'Error'
  data: {
    offset: number
    limit: number
    total: number
    count: number
    results: T[]
  }
  /**
   * The copyright notice for the returned result.
   */
  copyright: string
}

type Image = {
  path: string
  extension: string
}

type Character = {
  id: number
  name: string
  description: string
  thumbnail: Image
  comics: {
    available: number
    returned: number
    items: { resourceURI: string; name: string }[]
  }
  modified: string
}

type Comic = {
  id: number
  title: string
  description: string
  isbn: string
  pageCount: number
  thumbnail: Image
  characters: {
    available: number
    returned: number
    items: { resourceURI: string; name: string; role: string }[]
  }
}

// https://developer.marvel.com/docs
type MarvelAPIPaths = {
  characters: {
    request: {}
    response: APIResponse<Character>
  }
  comics: {
    request: {}
    response: APIResponse<Comic>
  }
}

/**
 * Calls the Marvel API and returns the results.
 */
async function api<Path extends keyof MarvelAPIPaths>(
  path: Path,
  request: MarvelAPIPaths[Path]['request'],
): Promise<MarvelAPIPaths[Path]['response']> {
  // https://developer.marvel.com/documentation/authorization
  const ts = Date.now()
  const hash = crypto.createHash('md5').update(`${ts}${CONFIG.privateKey}${CONFIG.pubKey}`).digest('hex').toString()
  const apikey = CONFIG.pubKey

  const url = qs.stringifyUrl({
    url: `https://gateway.marvel.com/v1/public/${path}`,
    query: {
      ...request,
      ts,
      hash,
      apikey,
    },
  })

  const response = await fetch(url, {
    method: 'GET',
  }).then((res) => res.json())

  return response as MarvelAPIPaths[Path]['response']
}
