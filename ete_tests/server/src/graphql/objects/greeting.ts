import { inputObjectType } from 'nexus'

export const Greeting = inputObjectType({
  name: 'Greeting',
  definition(t) {
    /* Fields */
    t.field('language', { type: 'Language' })
    t.string('name')
    // t.field('options', { type: 'GreetingOptions' })
  },
})

export const GreetingOptions = inputObjectType({
  name: 'GreetingOptions',
  definition(t) {
    t.string('prefix')
  },
})
