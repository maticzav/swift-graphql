import { PrismaClient } from '@prisma/client'
import crypto from 'crypto'
import fetch from 'node-fetch'
import qs from 'query-string'

const CONFIG = {
  pubKey: process.env.MARVEL_PUBLIC_KEY!,
  privateKey: process.env.MARVEL_PRIVATE_KEY!,
}

const USERS = [
  {
    username: 'maticzav',
    password: 'swiftcool',
  },
  {
    username: 'johndoe',
    password: 'password',
  },
  {
    username: 'julia',
    password: 'strawberry',
  },
]

const COMMENTS = [
  'I love Marvel universe!',
  'Iron Man is the best!',
  "Who's your favourite character?",
  'I wish I was as strong as Thor.',
  'I think Iron Man would beat Batman...',
]

// ---------------------------------------------------------------------------

const prisma = new PrismaClient()

async function main() {
  console.log(CONFIG)

  // Characters

  const characters: Character[] = []

  let charsres = await api('characters', { limit: 100 })

  while (charsres.data && characters.length < charsres.data.total / 3) {
    characters.push(...charsres.data.results)

    const offset = 3 * characters.length
    console.log(`Searching characters... ${offset}/${charsres.data.total}`)

    charsres = await api('characters', { offset, limit: 100 })
  }

  console.log(`Found ${characters.length} characters!`)

  for (const character of characters) {
    if (!character.name || !character.description) {
      continue
    }

    // Create the character
    const res = await prisma.character.upsert({
      where: { id: character.id.toString() },
      create: {
        id: character.id.toString(),
        name: character.name,
        description: character.description,
        image: `${character.thumbnail.path}/standard_fantastic.${character.thumbnail.extension}`,
      },
      update: {},
    })

    console.log(`${res.name} character created!`)
  }

  // Comics

  const comics: Comic[] = []

  let comsres = await api('comics', { limit: 100 })

  while (comsres.data && comics.length < comsres.data.total / 100) {
    comics.push(...comsres.data.results)

    const offset = 100 * comics.length
    console.log(`Searching comics... ${offset}/${comsres.data.total}`)

    comsres = await api('comics', { offset, limit: 100 })
  }

  console.log(`Found ${comics.length} comics!`)

  for (const comic of comics) {
    if (!comic.title || !comic.description) {
      continue
    }

    // Create the character
    const res = await prisma.comic.upsert({
      where: { id: comic.id.toString() },
      create: {
        id: comic.id.toString(),
        title: comic.title,
        description: comic.description,
        thumbnail: `${comic.thumbnail.path}/portrait_fantastic.${comic.thumbnail.extension}`,
        isbn: comic.isbn,
        pageCount: comic.pageCount,
      },
      update: {},
    })

    console.log(`${res.title} comic created!`)
  }

  // Connect characters and comics.

  for (const character of characters) {
    for (const comic of character.comics.items) {
      const comicid = getIdFromURI(comic.resourceURI)

      const res = await prisma.comic
        .update({
          where: { id: comicid.toString() },
          data: {
            characters: { connect: { id: character.id.toString() } },
          },
        })
        .catch(() => ({
          title: 'Unknown',
        }))

      console.log(`Connected ${res.title} and ${character.name}!`)
    }
  }

  const users = await Promise.all(
    USERS.map((user) =>
      prisma.user.upsert({
        where: { username: user.username },
        create: {
          username: user.username,
        },
        update: {},
      }),
    ),
  )

  console.log(`Seeded ${users.length} users!`)

  const comments = await Promise.all(
    COMMENTS.map((message, i) =>
      prisma.comment.create({
        data: {
          message,
          user: {
            connect: { id: users[i % users.length].id },
          },
        },
      }),
    ),
  )

  console.log(`Seeded ${comments.length} comments!`)
}

// Start

if (require.main === module) {
  main()
    .then(() => {
      console.log(`Seeding complete!`)
    })
    .catch((err) => {
      console.error(err)
    })
    .finally(async () => {
      await prisma.$disconnect()
    })
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
  } | null
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
  name: string | null
  description: string | null
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
  title: string | null
  description: string | null
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
    request: {
      limit?: number
      offset?: number
    }
    response: APIResponse<Character>
  }
  comics: {
    request: {
      limit?: number
      offset?: number
    }
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

/**
 * Returns an ID of the associated item in the URL.
 *
 * (e.g. http://gateway.marvel.com/v1/public/comics/21366 -> 21366)
 */
function getIdFromURI(uri: string): number {
  return parseInt(uri.split('/').pop()!)
}
