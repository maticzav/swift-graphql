export type Human = {
  type: 'Human'
  id: string
  name: string
  friends: string[]
  appears_in: number[]
  home_planet?: string
}

/**
 * Copied from GraphQL JS:
 *
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

/**
 * This defines a basic set of data for our Star Wars Schema.
 *
 * This data is hard coded for the sake of the demo, but you could imagine
 * fetching this data from a backend service rather than from hardcoded
 * JSON objects in a more complex demo.
 */

const luke = {
  type: 'Human',
  id: '1000',
  name: 'Luke Skywalker',
  friends: ['1002', '1003', '2000', '2001'],
  appears_in: [4, 5, 6],
  home_planet: 'Tatooine',
}

const vader = {
  type: 'Human',
  id: '1001',
  name: 'Darth Vader',
  friends: ['1004'],
  appears_in: [4, 5, 6],
  home_planet: 'Tatooine',
}

const han = {
  type: 'Human',
  id: '1002',
  name: 'Han Solo',
  friends: ['1000', '1003', '2001'],
  appears_in: [4, 5, 6],
}

const leia = {
  type: 'Human',
  id: '1003',
  name: 'Leia Organa',
  friends: ['1000', '1002', '2000', '2001'],
  appears_in: [4, 5, 6],
  home_planet: 'Alderaan',
}

const tarkin = {
  type: 'Human',
  id: '1004',
  name: 'Wilhuff Tarkin',
  friends: ['1001'],
  appears_in: [4],
}

const humanData = {
  '1000': luke,
  '1001': vader,
  '1002': han,
  '1003': leia,
  '1004': tarkin,
} as { [key in string]: Human }

export interface Data {
  allHumans: Human[]
  getHuman: (id: string) => Human | null
}

export const data = {
  /**
   * Contains all humans.
   */
  allHumans: Object.keys(humanData).map((key) => humanData[key]),
  /**
   * Allows us to query for the human with the given id.
   */
  getHuman: (id: string): Human | null => {
    return humanData[id] || null
  },
}
