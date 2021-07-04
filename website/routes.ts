import { IRoutes, GenerateRoutes } from '@guild-docs/server'

export function getRoutes(): IRoutes {
  const Routes: IRoutes = {
    _: {
      docs: {
        $name: 'Docs',
        $routes: ['README', 'installation', 'generation', 'selection', 'faq'],
        _: {
          reference: {
            $name: 'Reference',
            $routes: ['client', 'generator'],
          },
          advanced: {
            $name: 'Advanced',
            $routes: ['how', 'codecs'],
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
