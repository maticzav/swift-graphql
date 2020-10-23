import { inputObjectType } from '@nexus/schema'

export const Greeting = inputObjectType({
  name: 'Greeting',
  definition(t) {
    /* Fields */
    t.field('language', {
      type: 'Language',
      required: false,
    })
    t.string('name', { required: true })
    // t.field('options', { type: 'GreetingOptions' })
  },
})

export const GreetingOptions = inputObjectType({
  name: 'GreetingOptions',
  definition(t) {
    t.string('prefix')
  },
})
