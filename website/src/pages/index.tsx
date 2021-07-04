import Head from 'next/head'
import { FeatureList, HeroGradient, HeroIllustration, InfoList } from '@theguild/components'
import { handlePushRoute } from '@guild-docs/client'

export default function Index() {
  return (
    <>
      <Head>
        <title>SwiftGraphQL</title>
      </Head>
      <HeroGradient
        title="A GraphQL client that lets you forget about GraphQL"
        description=""
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
        colors={['#FB8A51', '#F25C40']}
        // image={{
        //   src: '/assets/home-claw.png',
        //   alt: 'Illustration',
        // }}
      />
      <FeatureList
        title="Features"
        items={[
          {
            image: {
              alt: 'Intuitive',
              src: '/assets/features-pluggable.png',
            },
            title: 'Intuitive',
            description: 'You will forget about the GraphQL layer altogether. Just Swift.',
          },
          {
            image: {
              alt: 'Flexible',
              src: '/assets/features-modern.png',
            },
            title: 'Query, Mutate & Subscribe',
            description: 'SwiftGraphQL supports query, mutation and subscription operations.',
          },
          {
            image: {
              alt: 'Develop Faster',
              src: '/assets/features-performant.png',
            },
            title: 'Robust',
            description: `If your project compiles, your queries work. You cannot make an invalid query that would compile.`,
          },
        ]}
      />

      <HeroIllustration
        title="How it works?"
        description="GraphQL Shield wrapps your schema resolvers and inteligently manages access to fields."
        image={{
          src: '/assets/home-communication.png',
          alt: 'Illustration',
        }}
        flipped
      />

      <InfoList
        title="Learn More"
        items={[
          {
            title: 'Why SwiftGraphQL?',
            description: 'Learn more about Envelop core and how it works',
            link: {
              href: '/docs',
              children: 'Documentation',
              title: 'Read the documentation',
              onClick: (e) => handlePushRoute('/docs', e),
            },
          },
          {
            title: 'F.A.Q',
            description: 'Find answers to most common questions about SwiftGraphQL',
            link: {
              href: '/docs/integrations',
              children: 'Integrations & Examples',
              title: 'Search examples',
              onClick: (e) => handlePushRoute('/docs/integrations', e),
            },
          },
        ]}
      />
    </>
  )
}
