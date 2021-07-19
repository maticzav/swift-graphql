import Head from 'next/head'
import { FeatureList, HeroGradient, HeroIllustration, InfoList } from '@theguild/components'
import { handlePushRoute } from '@guild-docs/client'
import { accentColor } from './_app'

export default function Index() {
  return (
    <>
      <HeroGradient
        title="A GraphQL client that lets you forget about GraphQL"
        description="SwiftGraphQL lets you decleratively write GraphQL queries using Swift language. This way you can be confident about your queries and develop faster. "
        link={{
          href: '/docs',
          children: 'Start Querying',
          title: 'Start programming with SwiftGraphQL',
          onClick: (e) => handlePushRoute('/docs', e),
        }}
        // version={
        //   <a href="https://www.npmjs.com/package/@envelop/core" target="_blank">
        //     <img src="https://badge.fury.io/js/%40envelop%2Fcore.svg" alt="npm version" height="18" />
        //   </a>
        // }
        colors={['#FD53F6', '#F35D41']}
        image={{
          src: '/assets/hero.png',
          alt: 'Illustration',
          style: {
            maxWidth: '34rem',
          },
        }}
      />

      <div style={{ paddingTop: '100px' }} />

      {/* Features */}

      <HeroIllustration
        title="Queries, Mutations & Subscriptions"
        description="SwiftGraphQL comes with a lightweight client that supports queries, mutations and subscriptions. And they all work the same way."
        image={{
          src: '/assets/client.png',
          alt: 'SwiftGraphQL client',
        }}
        flipped
      />

      <HeroIllustration
        title="If your project compiles, your queries work."
        description="We have set up SwiftGraphQL so that you cannot write invalid queries. Every query is backed by a Swift type to make sure everything is in-place."
        image={{
          src: '/assets/compile.png',
          alt: 'If it compiles, it works.',
        }}
      />

      <div style={{ paddingTop: '75px' }} />

      <HeroIllustration
        title="Develop Swift(ly)"
        description="You don’t have to worry about naming collisions, variables, anything. Just Swift. We use Swift in favour of GraphQL wherever possible."
        image={{
          src: '/assets/collisions.png',
          alt: 'Just Swift',
        }}
        flipped
      />

      <div style={{ paddingBottom: '100px' }} />

      <InfoList
        title="Learn more"
        itemLinkProps={{
          style: {
            color: accentColor,
          },
        }}
        items={[
          {
            title: 'Why SwiftGraphQL?',
            description: 'Learn more about Envelop core and how it works',
            link: {
              href: '/docs',
              children: 'The differences and idealogy',
              title: 'Learn what Swift GraphQL does differently',
              onClick: (e) => handlePushRoute('/docs/advanced/why', e),
            },
          },
          {
            title: 'Documentation',
            description: 'Dive right into how SwiftGraphQL works and start using it in your project.',
            link: {
              href: '/docs',
              children: 'Docs',
              title: 'Read the documentation',
              onClick: (e) => handlePushRoute('/docs', e),
            },
          },
          {
            title: 'F.A.Q',
            description: 'Find answers to most common questions about SwiftGraphQL',
            link: {
              href: '/docs/faq',
              children: 'Find a solution to your problem',
              title: 'Check questions',
              onClick: (e) => handlePushRoute('/docs/faq', e),
            },
          },
        ]}
      />

      <div style={{ paddingBottom: '100px' }} />
    </>
  )
}
