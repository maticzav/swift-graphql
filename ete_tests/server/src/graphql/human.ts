import { objectType } from '@nexus/schema'

export const Human = objectType({
  name: 'Human',
  description: 'A humanoid creature in the Star Wars universe.',
  definition(t) {
    t.implements('Character')

    t.id('id')
    t.string('name')

    t.string('homePlanet', {
      nullable: true,
      description: 'The home planet of the human, or null if unknown.',
      resolve: ({ home_planet }, _, ctx) => home_planet || null,
    })

    t.list.field('appearsIn', {
      type: 'Episode',
      resolve: ({ appears_in }) => appears_in,
    })
  },
})
