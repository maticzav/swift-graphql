import 'remark-admonitions/styles/infima.css'
import 'prism-themes/themes/prism-atom-dark.css'
import '../../public/style.css'
import '../../public/admonitions.css'

import { appWithTranslation } from 'next-i18next'
import { chakra, Code, Box, extendTheme, Text, theme as chakraTheme, UnorderedList, useColorModeValue } from '@chakra-ui/react'
import { mode } from '@chakra-ui/theme-tools'
import { CombinedThemeProvider, DocsPage, ExtendComponents, handlePushRoute } from '@guild-docs/client'
import { Footer, Header, Subheader } from '@theguild/components'
import { CopyToClipboard } from '../components/CopyToClipboard'
import { PackageInstall } from '../components/PackageInstall'

import type { AppProps } from 'next/app'

ExtendComponents({
  a: chakra('a', {
    baseStyle: {
      color: '#F25C40',
      _hover: {
        textDecoration: 'underline',
      },
    },
  }),
  pre: (props) => <div {...props} />,
  code: (props) => {
    return (
      <Code
        fontSize="0.9rem"
        colorScheme={'blackAlpha'}
        {...props}
        padding={'20px !important'}
        width={'100%'}
        borderRadius={'sm'}
      />
    )
  },
  inlineCode: (props) => {
    const colorScheme = useColorModeValue('blackAlpha', undefined)

    return <Code margin="1px" colorScheme={colorScheme} fontWeight="semibold" fontSize="0.875em" {...props} />
  },
  Text,
  PackageInstall,
  ul: UnorderedList,
})

const styles: typeof chakraTheme['styles'] = {
  global: (props) => ({
    body: {
      bg: mode('white', 'gray.850')(props),
    },
  }),
}

const theme = extendTheme({
  colors: {
    gray: {
      50: '#fafafa',
      100: '#f5f5f5',
      200: '#e5e5e5',
      300: '#d4d4d4',
      400: '#a3a3a3',
      500: '#737373',
      600: '#525252',
      700: '#404040',
      800: '#262626',
      850: '#1b1b1b',
      900: '#171717',
    },
  },
  fonts: {
    heading: '"Poppins", sans-serif',
    body: '"Poppins", sans-serif',
  },
  config: {
    initialColorMode: 'light',
    useSystemColorMode: true,
  },
  styles,
})

export const accentColor = '#F25C40'

const serializedMdx = process.env.SERIALIZED_MDX_ROUTES
const mdxRoutes = { data: serializedMdx && JSON.parse(serializedMdx) }

function AppContent(appProps: AppProps) {
  const { Component, pageProps, router } = appProps

  const isDocs = router.asPath.startsWith('/docs')

  return (
    <>
      <Header accentColor={accentColor} activeLink="/open-source" themeSwitch />
      <Subheader
        activeLink={router.asPath}
        product={{
          title: 'SwiftGraphQL',
          description: 'GraphQL client and Code Generator.',
          image: {
            src: '/swift.svg',
            alt: 'SwiftGraphQL Logo',
          },

          onClick: (e) => handlePushRoute('/', e),
        }}
        links={[
          {
            children: 'Home',
            title: 'The Guild SwiftGraphQL',
            href: '/',
            onClick: (e) => handlePushRoute('/', e),
          },
          {
            children: 'Docs & API',
            href: '/docs',
            title: 'Read more about SwiftGraphQL',
            onClick: (e) => handlePushRoute('/docs', e),
          },
          {
            children: 'GitHub',
            href: 'https://github.com/maticzav/swift-graphql',
            target: '_blank',
            rel: 'noopener norefereer',
            title: "Head to the project's GitHub",
          },
        ]}
        cta={{
          children: 'Get Started',
          href: '/docs',
          title: 'Start using SwiftGraphQL',
          onClick: (e) => handlePushRoute('/docs', e),
        }}
        ctaProps={{
          style: {
            background: 'linear-gradient(135.17deg, #F35D41 -7.39%, #FB8950 143.25%);',
          },
        }}
      />
      {isDocs ? <DocsPage accentColor={accentColor} appProps={appProps} mdxRoutes={mdxRoutes} /> : <Component {...pageProps} />}
      <Footer />
    </>
  )
}

const AppContentWrapper = appWithTranslation(function TranslatedApp(appProps) {
  return <AppContent {...appProps} />
})

export default function App(appProps: AppProps) {
  return (
    <CombinedThemeProvider
      theme={theme}
      accentColor={accentColor}
      defaultSeo={{
        title: 'SwiftGraphQL',
        description: 'A Swift GraphQL client and code generator.',
        logo: {
          url: 'https://swift-graphql.com/swift.svg',
          alt: 'SwiftGraphQL Logo',
        },
      }}
    >
      <AppContentWrapper {...appProps} />
    </CombinedThemeProvider>
  )
}
