module.exports = {
  sidebar: [
    { type: 'doc', id: 'index' },
    /* Docs */
    {
      type: 'category',
      label: 'Guides',
      items: [
        'guide/quick_start',
        'guide/selection',
        'guide/codecs',
        'guide/crazy',
      ],
      collapsed: false,
    },
    {
      type: 'category',
      label: 'Reference',
      items: [
        'ref/how',
        'ref/installation',
        'ref/config',
        'ref/selection',
        'ref/codecs',
      ],
      collapsed: false,
    },
    /* Sandbox */
    {
      type: 'link',
      label: 'Sandbox',
      href: '',
    },
  ],
}
