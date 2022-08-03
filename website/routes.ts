import { IRoutes, GenerateRoutes } from '@guild-docs/server'

export function getRoutes(): IRoutes {
  const Routes: IRoutes = {
    _: {
      docs: {
        $name: 'Docs',
        $routes: [
          //
          'README',
          'why',
          'installation',
          'network',
          'querying',
          'subscriptions',
          'guides',
          'advanced',
          'faq',
        ],
        _: {
          guides: {
            $name: 'Guides',
            $routes: [
              //
              'auth',
              'uploads',
              'filestructure',
            ],
          },
          advanced: {
            $name: 'Advanced',
            $routes: [
              //
              'scalars',
              'cache',
              'exchanges',
              'how',
              'selection',
            ],
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
