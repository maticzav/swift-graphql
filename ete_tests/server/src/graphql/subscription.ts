import { subscriptionType } from 'nexus'

/* Subscription */

export const Subscription = subscriptionType({
  definition(t) {
    t.int('number', {
      description:
        'Returns a random number every second. You should see it changing if your subscriptions work right.',
      subscribe() {
        return (async function* () {
          while (true) {
            await new Promise((res) => setTimeout(res, 1000))
            yield Math.floor(Math.random() * 100)
          }
        })()
      },
      resolve(eventData) {
        return eventData
      },
    })
  },
})
