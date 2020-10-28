import { interfaceType, idArg } from '@nexus/schema'

export const Character = interfaceType({
  name: 'Character',
  definition: (t) => {
    t.id('id', { description: 'The id of the character' })
    t.string('name', { description: 'The name of the character' })

    t.resolveType((character) => character.type)
  },
})
