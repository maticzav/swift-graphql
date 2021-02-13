module.exports = {
  title: 'SwiftGraphQL',
  tagline: 'A Swift client that lets you forget about GraphQL.',
  url: 'https://swift-graphql.org',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',
  organizationName: 'maticzav', // Usually your GitHub org/user name.
  projectName: 'swift-graphql', // Usually your repo name.
  themeConfig: {
    // Navigation
    navbar: {
      title: 'SwiftGraphQL',
      logo: {
        alt: 'SwiftGraphQL',
        src: 'img/logo.png',
      },
      items: [
        {
          to: '/docs/',
          activeBasePath: 'docs',
          label: 'Documentation',
          position: 'left',
        },
        { to: '/blog/', label: 'Blog', position: 'left' },
        {
          href: 'https://github.com/maticzav/swift-graphql/discussions',
          label: 'Forum',
          position: 'left',
        },
        {
          href: 'https://github.com/maticzav/swift-graphql',
          label: 'GitHub',
          position: 'left',
        },
      ],
    },
    // Footer
    footer: {
      style: 'light',
      links: [
        {
          title: 'Follow SwiftGraphQL',
          items: [
            {
              label: 'GitHub',
              to: 'https://github.com/maticzav',
            },
            {
              label: 'Twitter',
              to: 'https://twitter.com/maticzav',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Matic Zavadlal`,
    },
  },
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl:
            'https://github.com/maticzav/swift-graphql/edit/main/website/',
        },
        blog: {
          showReadingTime: true,
          editUrl:
            'https://github.com/maticzav/swift-graphql/edit/main/website/',
        },
        theme: {
          // customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
}
