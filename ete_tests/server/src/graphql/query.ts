import { objectType, idArg, arg } from '@nexus/schema'

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
        }),
      },
      nullable: true,
      resolve: (_, { id }, ctx) => ctx.data.getHuman(id),
    })

    /* Collections, Interfaces */

    t.list.field('humans', {
      type: 'Human',
      resolve: (_, {}, ctx) => ctx.data.allHumans,
    })

    t.list.field('droids', {
      type: 'Droid',
      resolve: (_, {}, ctx) => ctx.data.allDroids,
    })

    t.list.field('characters', {
      type: 'Character',
      resolve: (_, {}, ctx) => ctx.data.allCharacters,
    })

    /* Inputs */

    t.string('greeting', {
      args: {
        input: arg({
          type: 'Greeting',
          required: true,
        }),
      },
      resolve: (_, { input }, ctx) => {
        switch (input.language) {
          case 'EN':
            return `Hello ${input.name}`
          case 'SL':
          default:
            return `Pozdravljen ${input.name}`
        }
      },
    })
  },
})
