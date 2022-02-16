import { DateTimeResolver } from 'graphql-scalars'
import { IResolvers } from '@graphql-tools/utils'

import { Context } from './lib/sources'
import { AuthError, getToken } from './lib/auth'
import { getFileUpload } from './lib/aws'

export const resolvers: IResolvers<{}, Context> = {
  // Scalars
  DateTime: DateTimeResolver,

  // Root Resolvers
  Query: {
    hello: (parent, args, ctx) => 'Hello world!',
    user: (parent, args, ctx) => {},
    comics: async (parent, args, ctx) => {
      const { pagination } = args
      const { offset, limit } = pagination

      return ctx.prisma.comic.findMany({ skip: offset, take: limit })
    },
    characters: async (parent, args, ctx) => {
      const { pagination } = args
      const { offset, limit } = pagination

      return ctx.prisma.character.findMany({ skip: offset, take: limit })
    },
    search: async (parent, args, ctx) => {
      const { query } = args

      const { pagination } = args
      const { offset, limit } = pagination

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

      return [...characters, ...comics]
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
}
