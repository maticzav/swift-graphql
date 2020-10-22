import { objectType, idArg } from '@nexus/schema'
import * as data from '../data'

const characterArgs = {
  id: idArg({
    required: true,
    description: 'id of the character',
  }),
}

/* Query */

export const Query = objectType({
  name: 'Query',
  definition(t) {
    /* Singles */

    t.field('human', {
      type: 'Human',
      args: characterArgs,
      nullable: true,
      resolve: (_, { id }) => data.getHuman(id),
    })

    /* Collections */
    t.list.field('humans', {
      type: 'Human',
      resolve: () => data.allHumans,
    })
  },
})
