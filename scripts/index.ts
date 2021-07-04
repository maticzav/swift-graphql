import fs from 'fs'
import marked from 'marked'
import path from 'path'
import prettier from 'prettier'
import { promisify } from 'util'

const readfile = promisify(fs.readFile)
const writefile = promisify(fs.writeFile)

/**
 * Generates table of contents for a given markdown file and places it between
 * `<!-- index-start -->...<!-- index-end -->`.
 */

/* Config */

const MDPATH = path.resolve(__dirname, '../README.md')

/* Main */

async function main() {
  const file = await readfile(MDPATH).then((f) => f.toString())

  const TOC = generateTableOfContents(file)
  const updated = update(file, TOC)

  await writefile(MDPATH, updated)
  console.log('✅ Updated Table Of Contents!')
}

main()

/* Helper functions */

/**
 * Updates table of contents with a given index.
 */
function update(raw: string, index: string): string {
  index = `
  <!-- index-start -->
  ${index}
  <!-- index-end -->
  `

  const source = raw.replace(/<!-- index-start -->([\w\W]*)<!-- index-end -->/, index)

  return prettier.format(source, {
    parser: 'markdown',
  })
}

/**
 * Generates table of content out of the document.
 */
function generateTableOfContents(raw: string): string {
  // Strip irrelevatn part.
  const stripped = strip(raw)
  const lex = marked.lexer(stripped)

  // Abstract index.
  let index: IndexItem[] = []

  for (const item of lex as Token[]) {
    // Sometimes we might have unexpected object type.
    if (typeof item['type'] !== 'string') {
      continue
    }

    switch (item.type) {
      case 'heading': {
        index.push({ name: item.text, depth: item.depth })
      }
    }
  }

  // Parse table
  let parsed = ''

  const indentation = Math.min(...index.map((item) => item.depth))

  for (const item of index) {
    const indent = ' '.repeat((item.depth - indentation) * 2)
    parsed += `\n${indent} - [${item.name}](#${linkify(item.name)})`
  }

  return parsed
}

/**
 * Removes parts that are irrelevant for creating index.
 */
function strip(raw: string): string {
  const pattern = /<!-- index-end -->[\n\s]+([\w\W.]*)/
  return pattern.exec(raw)[1]
}

/**
 * Returns a heading link that may be used to navigate around.
 */
function linkify(heading: string): string {
  return heading
    .toLowerCase()
    .split(/\s+/)
    .join('-')
    .replace(/[^-\w]/g, '')
}

/**
 * Represents a single heading that we've parsed.
 */
type IndexItem = { name: string; depth: number }

type Token =
  | marked.Tokens.Space
  | marked.Tokens.Code
  | marked.Tokens.Heading
  | marked.Tokens.Table
  | marked.Tokens.Hr
  | marked.Tokens.Blockquote
  | marked.Tokens.BlockquoteStart
  | marked.Tokens.BlockquoteEnd
  | marked.Tokens.List
  | marked.Tokens.ListItem
  | marked.Tokens.Paragraph
  | marked.Tokens.HTML
  | marked.Tokens.Text
  | marked.Tokens.Escape
  | marked.Tokens.Tag
  | marked.Tokens.Image
  | marked.Tokens.Link
  // | marked.Tokens.Df
  | marked.Tokens.Strong
  | marked.Tokens.Em
  | marked.Tokens.Codespan
  | marked.Tokens.Br
  | marked.Tokens.Del
