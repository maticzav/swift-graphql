import React from 'react'
import Layout from '@theme/Layout'
import Link from '@docusaurus/Link'
import useBaseUrl from '@docusaurus/useBaseUrl'

import styles from './styles.module.css'
import { Feature } from '../components/feature'
import clsx from 'clsx'

/* Page */

/**
 * Home page is a landing page that user gets to to
 */
export default function Home() {
  /* Constants */

  const thumbnailBackgroundURL = useBaseUrl('./img/thumbnail.png')

  /* Page */

  return (
    <Layout
      title={`SwiftGraphQL`}
      description="A Swift client that lets you forget about GraphQL."
    >
      {/* Header */}
      <header className="container">
        <img
          className={styles.thumbnail}
          src={thumbnailBackgroundURL}
          alt={'SwiftGraphQL Background'}
        />
      </header>

      {/*  */}
      {/* Main */}
      <main className="container">
        <h2 className={styles.featuresTitle}>Features</h2>
        <section className={styles.features}>
          <div className="row">
            {features.map((props, idx) => (
              <Feature key={idx} {...props} />
            ))}
          </div>
        </section>
      </main>
      {/*  */}
    </Layout>
  )
}

/* Content */

const features = [
  {
    title: 'TypeSafe',
    imageUrl: 'img/undraw_docusaurus_mountain.svg',
    description: (
      <>
        SwiftGraphQL was designed ground up to be end-to-end type-safe. If your
        project compiles, we guarantee that queries are valid.
      </>
    ),
  },
  {
    title: 'Focus on What Matters',
    imageUrl: 'img/undraw_docusaurus_tree.svg',
    description: (
      <>
        Docusaurus lets you focus on your docs, and we&apos;ll do the chores. Go
        ahead and move your docs into the <code>docs</code> directory.
      </>
    ),
  },
  {
    title: 'Lightweight',
    imageUrl: 'img/undraw_docusaurus_react.svg',
    description: <></>,
  },
]
