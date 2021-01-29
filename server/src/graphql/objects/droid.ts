import { objectType } from 'nexus'

export const Droid = objectType({
  name: 'Droid',
  definition(t) {
    t.implements('Character')

    t.id('id')
    t.string('name')
    t.string('primaryFunction', {
      resolve: ({ primary_function }) => primary_function,
    })

    t.list.field('appearsIn', {
      type: 'Episode',
      resolve: ({ appears_in }) => appears_in,
    })
  },
})
