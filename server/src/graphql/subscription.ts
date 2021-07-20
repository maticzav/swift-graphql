import { subscriptionType } from 'nexus'

import { wait } from '../utils'

/* Subscription */

export const Subscription = subscriptionType({
  definition(t) {
    t.int('number', {
      description: 'Returns a random number every second. You should see it changing if your subscriptions work right.',
      subscribe() {
        return (async function* () {
          while (true) {
            await wait(1000)
            yield Math.floor(Math.random() * 100)
          }
        })()
      },
      resolve(eventData: number) {
        return eventData
      },
    })
  },
})
