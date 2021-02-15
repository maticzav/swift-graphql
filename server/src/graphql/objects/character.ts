import { interfaceType, idArg, unionType } from 'nexus'

export const Character = interfaceType({
  name: 'Character',
  resolveType: (character) => character.type,
  definition: (t) => {
    t.id('id', { description: 'The id of the character' })
    t.string('name', { description: 'The name of the character' })
  },
})

export const CharacterUnion = unionType({
  name: 'CharacterUnion',
  resolveType: (character) => character.type,
  definition(t) {
    t.members('Human', 'Droid')
  },
})
