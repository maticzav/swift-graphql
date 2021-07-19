import { IRoutes, GenerateRoutes } from '@guild-docs/server'

export function getRoutes(): IRoutes {
  const Routes: IRoutes = {
    _: {
      docs: {
        $name: 'Docs',
        $routes: ['README', 'installation', 'generation', 'querying', 'selection', 'faq'],
        _: {
          advanced: {
            $name: 'Advanced',
            $routes: ['why', 'how', 'codecs'],
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
