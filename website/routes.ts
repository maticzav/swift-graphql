import { IRoutes, GenerateRoutes } from '@guild-docs/server'

export function getRoutes(): IRoutes {
  const Routes: IRoutes = {
    _: {
      docs: {
        $name: 'Docs',
        $routes: ['README', 'installation', 'querying', 'swiftui', 'guides', 'advanced', 'reference', 'faq'],
        _: {
          guides: {
            $name: 'Guides',
            $routes: ['generation', 'structure', 'auth', 'files'],
          },
          advanced: {
            $name: 'Advanced',
            $routes: ['selection', 'cache', 'codecs', 'why', 'how'],
          },
          reference: {
            $name: 'Reference',
            $routes: ['client', 'generator'],
          },
        },
      },
    },
  }

  GenerateRoutes({
    Routes,
    folderPattern: 'docs',
    basePath: 'docs',
    basePathLabel: 'Documentation',
    labels: {},
  })

  return Routes
}
