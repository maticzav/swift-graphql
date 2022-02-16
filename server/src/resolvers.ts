import { DateTimeResolver } from 'graphql-scalars'
import { IResolvers } from '@graphql-tools/utils'

import { Context } from './lib/sources'
import { AuthError, getToken } from './lib/auth'
import { getFileUpload } from './lib/aws'

export const resolvers: IResolvers<any, Context> = {
  // Scalars
  DateTime: DateTimeResolver,

  // Root Resolvers
  Query: {
    hello: (parent, args, ctx) => 'Hello world!',
    user: (parent, args, ctx) => {
      if (!ctx.user?.id) {
        throw new AuthError()
      }

      return ctx.prisma.user.findUnique({
        where: { id: ctx.user.id },
      })
    },
    node: async (parent, args, ctx) => {
      const id = parseInt(args.id)

      const character = await ctx.prisma.character.findUnique({ where: { id } })

      if (character) {
        return {
          __typename: 'Character',
          ...character,
        }
      }

      const comic = await ctx.prisma.comic.findUnique({ where: { id } })

      if (comic) {
        return {
          __typename: 'Comic',
          ...comic,
        }
      }

      const user = await ctx.prisma.user.findUnique({ where: { id } })

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
      const limit = args?.pagination?.limit ?? 50

      return ctx.prisma.comic.findMany({ skip: offset, take: limit })
    },
    characters: async (parent, args, ctx) => {
      const offset = args?.pagination?.offset ?? 0
      const limit = args?.pagination?.limit ?? 50

      return ctx.prisma.character.findMany({ skip: offset, take: limit })
    },
    search: async (parent, args, ctx) => {
      const { query } = args

      const offset = args?.pagination?.offset ?? 0
      const limit = args?.pagination?.limit ?? 50

      const characters = await ctx.prisma.character.findMany({
        where: {
          name: { startsWith: query },
        },
        skip: offset,
        take: limit,
      })

      const comics = await ctx.prisma.comic.findMany({
        where: {
          title: { startsWith: query },
        },
        skip: offset,
        take: limit,
      })

      return [
        ...characters.map((c) => ({ ...c, __typename: 'Character' })),
        ...comics.map((c) => ({ ...c, __typename: 'Comic' })),
      ]
    },
  },
  Mutation: {
    auth: async (parent, { username, password }, ctx) => {
      const user = await ctx.prisma.user.upsert({
        where: { username },
        create: {
          username,
          password,
        },
        update: {},
      })

      if (user.password !== password) {
        return {
          __typename: 'AuthPayloadFailure',
          message: `Incorrect password!`,
        }
      }

      return {
        __typename: 'AuthPayloadSuccess',
        token: getToken(user.id),
        user,
      }
    },
    updateAvatar: async (parent, args, ctx) => {
      if (!ctx.user?.id) {
        throw new AuthError()
      }

      return ctx.prisma.user.update({
        where: { id: ctx.user.id },
        data: {
          picture: {
            connect: { id: args.id },
          },
        },
      })
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
          return ctx.prisma.character.findUnique({
            where: { id: star.referenceId },
          })
        }
        case 'COMIC': {
          return ctx.prisma.comic.findUnique({
            where: { id: star.referenceId },
          })
        }
        default: {
          throw new Error(`Unknown kind: ${star.kind}!`)
        }
      }
    },
    comment: async (parent, args, ctx) => {
      if (!ctx.user?.id) {
        throw new AuthError()
      }

      return ctx.prisma.comment.create({
        data: {
          message: args.message,
          user: { connect: { id: ctx.user.id } },
        },
      })
    },
    uploadFile: async (parent, args, ctx) => {
      if (!ctx.user?.id) {
        throw new AuthError()
      }

      const awsFile = await getFileUpload({
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
      subscribe: (parent, args, ctx) => {},
    },
    commented: {
      subscribe: (parent, args, ctx) => {},
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
    comics: ({ id }, args, ctx) => {
      return ctx.prisma.character
        .findUnique({
          where: { id },
        })
        .comics()
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
    characters: ({ id }, args, ctx) => {
      return ctx.prisma.comic
        .findUnique({
          where: { id },
        })
        .characters()
    },
  },
}
