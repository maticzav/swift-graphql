import { YogaInitialContext } from '@graphql-yoga/node'

export interface Context extends YogaInitialContext {
  user: { name: string } | null
}
