import { objectType } from 'nexus'

export const Human = objectType({
  name: 'Human',
  description: 'A humanoid creature in the Star Wars universe.',
  definition(t) {
    t.implements('Character')

    t.id('id')
    t.string('name')

    t.nullable.string('homePlanet', {
      description: 'The home planet of the human, or null if unknown.',
      resolve: ({ home_planet }, _, ctx) => home_planet || null,
    })

    t.list.field('appearsIn', {
      type: 'Episode',
      resolve: ({ appears_in }) => appears_in,
    })

    /* Test casing */

    t.nullable.string('infoURL', {
      resolve: ({ info }) => info || null,
    })
  },
})
