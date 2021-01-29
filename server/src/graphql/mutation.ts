import { objectType, idArg, arg, mutationType } from 'nexus'
import { getAuthorization } from '../utils'

/* Mutation */

export const Mutation = mutationType({
  definition(t) {
    /* Random mutation, we should improve it one day. */

    t.boolean('mutate', {
      resolve: () => true,
    })
  },
})
