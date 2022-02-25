import { Comment } from '@prisma/client'
import { DateTimeResolver } from 'graphql-scalars'
import { DateTime } from 'luxon'

import { Context } from './lib/sources'
import { AuthError, getToken } from './lib/auth'
import { getFileUploadValues } from './lib/aws'
import { Resolvers } from './types'
import { generateRandomName } from './lib/random'

export const resolvers: Resolvers<Context> = {
  // Scalars
  DateTime: DateTimeResolver,

  // Root Resolvers
  Query: {
    hello: (parent, args, ctx) => 'Hello world!',
    user: async (parent, args, ctx) => {
      if (!ctx.user?.id) {
        throw new AuthError()
      }

      const user = await ctx.prisma.user.findUnique({
        where: { id: ctx.user.id },
      })

      if (user == null) {
        throw new AuthError()
      }

      return user
    },
    node: async (parent, args, ctx) => {
      const character = await ctx.prisma.character.findUnique({
        where: { id: args.id },
      })

      if (character) {
        return {
          __typename: 'Character',
          ...character,
        }
      }

      const comic = await ctx.prisma.comic.findUnique({
        where: { id: args.id },
      })

      if (comic) {
        return {
          __typename: 'Comic',
          ...comic,
        }
      }

      const user = await ctx.prisma.user.findUnique({
        where: { id: args.id },
      })

      if (user) {
        return {
          __typename: 'User',
          ...user,
        }
      }

      return null
    },
    comics: async (parent, args, ctx) => {
      const offset = args?.pagination?.offset ?? 0
      const limit = args?.pagination?.take ?? 50

      return ctx.prisma.comic.findMany({
        include: {
          characters: true,
        },
        skip: offset,
        take: limit,
        orderBy: { title: 'asc' },
      })
    },
    characters: async (parent, args, ctx) => {
      const offset = args?.pagination?.offset ?? 0
      const limit = args?.pagination?.take ?? 50

      return ctx.prisma.character.findMany({ skip: offset, take: limit })
    },
    search: async (parent, { query }, ctx) => {
      const offset = query?.pagination?.offset ?? 0
      const limit = query?.pagination?.take ?? 50

      const characters = await ctx.prisma.character.findMany({
        where: {
          name: { startsWith: query.query },
        },
        skip: offset,
        take: limit,
      })

      const comics = await ctx.prisma.comic.findMany({
        where: {
          title: { startsWith: query.query },
        },
        skip: offset,
        take: limit,
      })

      return [
        ...characters.map((c) => ({ ...c, __typename: 'Character' as const })),
        ...comics.map((c) => ({ ...c, __typename: 'Comic' as const })),
      ]
    },
  },
  Mutation: {
    auth: async (parent, args, ctx) => {
      const user = await ctx.prisma.user.create({
        data: {
          username: generateRandomName(),
        },
      })

      return {
        __typename: 'AuthPayloadSuccess',
        token: getToken(user.id),
        user,
      }
    },
    star: async (parent, args, ctx) => {
      if (!ctx.user?.id) {
        throw new AuthError()
      }

      const star = await ctx.prisma.star.create({
        data: {
          kind: args.item,
          referenceId: args.id,
          user: { connect: { id: ctx.user.id } },
        },
      })

      switch (star.kind) {
        case 'CHARACTER': {
          return ctx.prisma.character
            .findUnique({
              where: { id: star.referenceId },
            })
            .then((res) => res!)
        }
        case 'COMIC': {
          return ctx.prisma.comic
            .findUnique({
              where: { id: star.referenceId },
            })
            .then((res) => res!)
        }
        default: {
          throw new Error(`Unknown kind: ${star.kind}!`)
        }
      }
    },
    message: async (parent, args, ctx) => {
      if (!ctx.user?.id) {
        throw new AuthError()
      }

      const message = await ctx.prisma.comment.create({
        data: {
          message: args.message,
          user: { connect: { id: ctx.user.id } },
        },
      })

      ctx.pubsub.publish('MESSAGE', message)

      return message
    },
    uploadFile: async (parent, args, ctx) => {
      if (!ctx.user?.id) {
        throw new AuthError()
      }

      const awsFile = await getFileUploadValues({
        contentType: args.contentType,
        extension: args.extension,
        folder: args.folder,
      })

      return {
        __typename: 'File',
        id: awsFile.file.id,
        url: awsFile.upload_url,
      }
    },
  },
  Subscription: {
    time: {
      subscribe: async function* (parent, args, ctx) {
        while (true) {
          await new Promise((resolve) => setTimeout(resolve, 1000))
          yield DateTime.now().toJSDate()
        }
      },
      resolve: (payload: Date) => payload,
    },
    message: {
      subscribe: async function* (parent, args, ctx) {
        return ctx.pubsub.subscribe('MESSAGE')
      },
      resolve: async (payload: Comment) => payload,
    },
  },

  // Types

  Character: {
    starred: async (parent, args, ctx) => {
      if (!ctx.user?.id) {
        return false
      }

      const n = await ctx.prisma.star.count({
        where: {
          kind: 'CHARACTER',
          referenceId: parent.id,
          userId: ctx.user.id,
        },
      })

      return n > 0
    },
  },
  Comic: {
    starred: async (parent, args, ctx) => {
      if (!ctx.user?.id) {
        return false
      }

      const n = await ctx.prisma.star.count({
        where: {
          kind: 'COMIC',
          referenceId: parent.id,
          userId: ctx.user.id,
        },
      })

      return n > 0
    },
  },
}
