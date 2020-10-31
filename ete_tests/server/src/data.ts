/**
 * Copied from GraphQL JS:
 *
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import { Character, Data, Droid, Human } from './types/backingTypes'

/**
 * This defines a basic set of data for our Star Wars Schema.
 *
 * This data is hard coded for the sake of the demo, but you could imagine
 * fetching this data from a backend service rather than from hardcoded
 * JSON objects in a more complex demo.
 */

/* Humans */

const luke: Human = {
  type: 'Human',
  id: '1000',
  name: 'Luke Skywalker',
  friends: ['1002', '1003'],
  appears_in: [4, 5, 6],
  home_planet: 'Tatooine',
  info: 'https://en.wikipedia.org/wiki/Luke_Skywalker',
}

const vader: Human = {
  type: 'Human',
  id: '1001',
  name: 'Darth Vader',
  friends: ['1004'],
  appears_in: [4, 5, 6],
  home_planet: 'Tatooine',
}

const han: Human = {
  type: 'Human',
  id: '1002',
  name: 'Han Solo',
  friends: ['1000', '1003'],
  appears_in: [4, 5, 6],
}

const leia: Human = {
  type: 'Human',
  id: '1003',
  name: 'Leia Organa',
  friends: ['1000', '1002'],
  appears_in: [4, 5, 6],
  home_planet: 'Alderaan',
}

const tarkin: Human = {
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

/* Droids */

const threepio: Droid = {
  type: 'Droid',
  id: '2000',
  name: 'C-3PO',
  friends: ['1000', '1002', '1003', '2001'],
  appears_in: [4, 5, 6],
  primary_function: 'Protocol',
}

const artoo: Droid = {
  type: 'Droid',
  id: '2001',
  name: 'R2-D2',
  friends: ['1000', '1002', '1003'],
  appears_in: [4, 5, 6],
  primary_function: 'Astromech',
}

const droidData = {
  '2000': threepio,
  '2001': artoo,
} as { [key in string]: Droid }

/* Data */

export const data: Data = {
  allHumans: Object.values(humanData),
  allDroids: Object.values(droidData),
  allCharacters: [...Object.values(humanData), ...Object.values(droidData)],
  getHuman: (id: string): Human | null => {
    return humanData[id] || null
  },
  getDroid: (id: string): Droid | null => {
    return droidData[id] || null
  },
  getCharacter: (id: string): Character | null => {
    return humanData[id] || droidData[id] || null
  },
}
