import { Request } from 'express'
import { NexusGenEnums } from '../nexus.types'

export interface ContextType {
  req: Request
  data: Data
}

/* Data */
export interface Data {
  /**
   * Returns all droids.
   */
  allDroids: Droid[]
  /**
   * Returns all humans.
   */
  allHumans: Human[]
  /**
   * Returns all characters.
   */
  allCharacters: Character[]
  /**
   * Returns a human with an id.
   */
  getHuman: (id: string) => Human | null
  /**
   * Returns a droid with an id.
   */
  getDroid: (id: string) => Droid | null
  /**
   * Returns a character with an id.
   */
  getCharacter: (id: string) => Character | null
}

/* Data Types */

export type Human = {
  type: 'Human'
  id: string
  name: string
  friends: string[]
  appears_in: NexusGenEnums['Episode'][]
  home_planet?: string
  info?: string
}

export type Droid = {
  type: 'Droid'
  id: string
  name: string
  friends: string[]
  appears_in: NexusGenEnums['Episode'][]
  primary_function: string
}

export type Character = Human | Droid
