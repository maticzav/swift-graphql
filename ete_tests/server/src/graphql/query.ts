import { objectType, idArg } from '@nexus/schema'
import * as data from '../data'

/* Query */

export const Query = objectType({
  name: 'Query',
  definition(t) {
    /* Singles */

    t.field('human', {
      type: 'Human',
      args: {
        id: idArg({
          required: true,
          description: 'id of the character',
        })
      },
      nullable: true,
      resolve: (_, { id }) => data.getHuman(id),
    })

    /* Collections */
    t.list.id("test", {
      resolve: () => []
    })
    t.list.field('humans', {
      type: 'Human',
      resolve: () => data.allHumans,
    })
  },
})
