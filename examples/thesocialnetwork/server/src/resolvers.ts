import * as crypto from 'bcryptjs'
import { DateTimeResolver } from 'graphql-scalars'
import { DateTime } from 'luxon'

import { AuthError } from './lib/auth'
import * as aws from './lib/aws'
import { Context } from './lib/context'

import { Resolvers } from './types'

export const resolvers: Resolvers<Context> = {
  // Scalars
  DateTime: DateTimeResolver,

  // Root Resolvers
  Query: {
    viewer: async (parent, args, ctx) => {
      if (!ctx.user) {
        return null
      }

      const user = await ctx.prisma.user.findUnique({
        where: { id: ctx.user.id },
        select: {
          id: true,
          username: true,
          picture: true,
        },
      })

      if (!user) {
        throw new Error('User not found')
      }

      return {
        id: user.id,
        username: user.username,
        picture: user.picture?.url,
        isViewer: true,
      }
    },
    feed: async (parent, args, ctx) => {
      if (!ctx.user) {
        throw new AuthError()
      }

      const unread = ctx.mailbox.drain(ctx.user.id)
      const rawfeed = await ctx.prisma.message.findMany({
        select: {
          id: true,
          createdAt: true,
          message: true,
          sender: {
            select: {
              id: true,
              username: true,
              picture: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
        take: unread + 20,
      })

      const feed = rawfeed.map((message) => {
        return {
          id: message.id,
          createdAt: message.createdAt,
          message: message.message,
          sender: {
            id: message.sender.id,
            username: message.sender.username,
            picture: message.sender.picture?.url,
            isViewer: false,
          },
        }
      })

      return feed
    },
  },
  Mutation: {
    login: async (parent, { username, password }, ctx) => {
      // Try login with username and password
      const existing = await ctx.prisma.user.findUnique({
        where: { username: username },
      })

      if (existing) {
        const isValid = await crypto.compare(password, existing.password)
        if (!isValid) {
          return { __typename: 'AuthPayloadFailure', message: 'Invalid password!' }
        }

        ctx.mailbox.createUserMailbox(existing.id)
        const token = ctx.sessions.createSessionForUser(existing.id)
        return { __typename: 'AuthPayloadSuccess', token }
      }

      // Create a new user
      if (username.length <= 3) {
        return {
          __typename: 'AuthPayloadFailure',
          message: 'Username too short!',
        }
      }

      const hashedPassword = await crypto.hash(password, 42)
      const user = await ctx.prisma.user.create({
        data: { username, password: hashedPassword },
      })

      ctx.mailbox.createUserMailbox(user.id)

      return {
        __typename: 'AuthPayloadSuccess',
        token: ctx.sessions.createSessionForUser(user.id),
      }
    },
    getProfilePictureSignedURL: async (parent, { extension, contentType }, ctx) => {
      if (!ctx.user) {
        throw new AuthError()
      }

      const { file_url, upload_url } = await aws.getFileUploadValues({ extension, contentType, folder: 'profile_pictures' })

      const file = await ctx.prisma.file.create({
        data: { contentType, url: file_url },
      })

      return { file_id: file.id, upload_url }
    },
    setProfilePicture: async (parent, { file }, ctx) => {
      if (!ctx.user) {
        throw new AuthError()
      }

      const user = await ctx.prisma.user.update({
        where: { id: ctx.user.id },
        data: {
          picture: { connect: { id: file } },
        },
        select: { id: true, username: true, picture: true },
      })

      return {
        id: user.id,
        username: user.username,
        picture: user.picture?.url,
        isViewer: true,
      }
    },
    message: async (parent, args, ctx) => {
      if (!ctx.user) {
        throw new AuthError()
      }

      const msg = await ctx.prisma.message.create({
        data: {
          message: args.message,
          sender: { connect: { id: ctx.user.id } },
        },
        select: {
          id: true,
          createdAt: true,
          message: true,
          sender: {
            select: { id: true, username: true, picture: true },
          },
        },
      })

      if (msg == null) {
        return null
      }

      for (const { userId, count } of ctx.mailbox.received(1)) {
        ctx.pubsub.publish(`mailbox`, userId, { count })
      }

      return {
        id: msg.id,
        createdAt: msg.createdAt,
        message: msg.message,
        sender: {
          id: msg.sender.id,
          username: msg.sender.username,
          picture: msg.sender.picture?.url,
          isViewer: true,
        },
      }
    },
  },
  Subscription: {
    time: {
      // This will return the value on every 1 sec until it reaches 0
      subscribe: async function* (_, {}) {
        while (true) {
          await new Promise((resolve) => setTimeout(resolve, 1000))
          yield { time: DateTime.now().toJSDate() }
        }
      },
    },
    messages: {
      subscribe: (_, {}, ctx) => {
        if (!ctx.user) {
          throw new AuthError()
        }
        return ctx.pubsub.subscribe(`mailbox`, ctx.user.id)
      },
      resolve: (payload: { count: number }) => {
        return payload.count
      },
    },
  },

  // Types

  User: {
    isViewer: (parent, args, ctx) => {
      if (!ctx.user) {
        return false
      }
      return parent.id === ctx.user.id
    },
  },
}
