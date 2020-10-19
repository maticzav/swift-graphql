import { objectType, arg, stringArg } from '@nexus/schema'
import * as data from '../data'

const characterArgs = {
  id: stringArg({
    required: true,
    description: 'id of the character',
  }),
}

const heroArgs = {
  episode: arg({
    type: 'Episode',
    description:
      'If omitted, returns the hero of the whole saga. If provided, returns the hero of that particular episode.',
  }),
}

/* Query */

export const Query = objectType({
  name: 'Query',
  definition(t) {
    /* Singles */
    t.field('hero', {
      type: 'Character',
      args: heroArgs,
      resolve: (_, { episode }) => data.getHero(episode),
    })

    t.field('human', {
      type: 'Human',
      args: characterArgs,
      resolve: (_, { id }) => data.getHuman(id),
    })

    t.field('droid', {
      type: 'Droid',
      args: characterArgs,
      resolve: (_, { id }) => data.getDroid(id),
    })

    /* Collections */

    t.field('humans', {
      type: 'Human',
      list: true,
      nullable: false,
      resolve: () => data.allHumans,
    })
  },
})
