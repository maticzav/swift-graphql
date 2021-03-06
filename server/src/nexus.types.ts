/**
 * This file was generated by Nexus Schema
 * Do not make changes to this file directly
 */

import * as swapi from './types/backingTypes'
import { ContextType } from './types/backingTypes'
import { core } from 'nexus'
declare global {
  interface NexusGenCustomInputMethods<TypeName extends string> {
    /**
     * Date custom scalar type
     */
    date<FieldName extends string>(fieldName: FieldName, opts?: core.CommonInputFieldConfig<TypeName, FieldName>): void // "Date";
  }
}
declare global {
  interface NexusGenCustomOutputMethods<TypeName extends string> {
    /**
     * Date custom scalar type
     */
    date<FieldName extends string>(fieldName: FieldName, ...opts: core.ScalarOutSpread<TypeName, FieldName>): void // "Date";
  }
}

declare global {
  interface NexusGen extends NexusGenTypes {}
}

export interface NexusGenInputs {
  Greeting: {
    // input type
    language?: NexusGenEnums['Language'] | null // Language
    name: string // String!
  }
  GreetingOptions: {
    // input type
    prefix?: string | null // String
  }
}

export interface NexusGenEnums {
  Episode: 5 | 6 | 4
  Language: 'EN' | 'SL'
}

export interface NexusGenScalars {
  String: string
  Int: number
  Float: number
  Boolean: boolean
  ID: string
  Date: any
}

export interface NexusGenObjects {
  Droid: swapi.Droid
  Human: swapi.Human
  Mutation: {}
  Query: {}
  Subscription: {}
}

export interface NexusGenInterfaces {
  Character: swapi.Character
}

export interface NexusGenUnions {
  CharacterUnion: NexusGenRootTypes['Droid'] | NexusGenRootTypes['Human']
}

export type NexusGenRootTypes = NexusGenInterfaces & NexusGenObjects & NexusGenUnions

export type NexusGenAllTypes = NexusGenRootTypes & NexusGenScalars & NexusGenEnums

export interface NexusGenFieldTypes {
  Droid: {
    // field return type
    appearsIn: NexusGenEnums['Episode'][] // [Episode!]!
    id: string // ID!
    name: string // String!
    primaryFunction: string // String!
  }
  Human: {
    // field return type
    appearsIn: NexusGenEnums['Episode'][] // [Episode!]!
    homePlanet: string | null // String
    id: string // ID!
    infoURL: string | null // String
    name: string // String!
  }
  Mutation: {
    // field return type
    mutate: boolean // Boolean!
  }
  Query: {
    // field return type
    character: NexusGenRootTypes['CharacterUnion'] | null // CharacterUnion
    characters: NexusGenRootTypes['Character'][] // [Character!]!
    droid: NexusGenRootTypes['Droid'] | null // Droid
    droids: NexusGenRootTypes['Droid'][] // [Droid!]!
    greeting: string // String!
    human: NexusGenRootTypes['Human'] | null // Human
    humans: NexusGenRootTypes['Human'][] // [Human!]!
    luke: NexusGenRootTypes['Human'] | null // Human
    time: NexusGenScalars['Date'] // Date!
    whoami: string // String!
  }
  Subscription: {
    // field return type
    number: number // Int!
  }
  Character: {
    // field return type
    id: string // ID!
    name: string // String!
  }
}

export interface NexusGenFieldTypeNames {
  Droid: {
    // field return type name
    appearsIn: 'Episode'
    id: 'ID'
    name: 'String'
    primaryFunction: 'String'
  }
  Human: {
    // field return type name
    appearsIn: 'Episode'
    homePlanet: 'String'
    id: 'ID'
    infoURL: 'String'
    name: 'String'
  }
  Mutation: {
    // field return type name
    mutate: 'Boolean'
  }
  Query: {
    // field return type name
    character: 'CharacterUnion'
    characters: 'Character'
    droid: 'Droid'
    droids: 'Droid'
    greeting: 'String'
    human: 'Human'
    humans: 'Human'
    luke: 'Human'
    time: 'Date'
    whoami: 'String'
  }
  Subscription: {
    // field return type name
    number: 'Int'
  }
  Character: {
    // field return type name
    id: 'ID'
    name: 'String'
  }
}

export interface NexusGenArgTypes {
  Query: {
    character: {
      // args
      id: string // ID!
    }
    droid: {
      // args
      id: string // ID!
    }
    greeting: {
      // args
      input?: NexusGenInputs['Greeting'] | null // Greeting
    }
    human: {
      // args
      id: string // ID!
    }
  }
}

export interface NexusGenAbstractTypeMembers {
  CharacterUnion: 'Droid' | 'Human'
  Character: 'Droid' | 'Human'
}

export interface NexusGenTypeInterfaces {
  Droid: 'Character'
  Human: 'Character'
}

export type NexusGenObjectNames = keyof NexusGenObjects

export type NexusGenInputNames = keyof NexusGenInputs

export type NexusGenEnumNames = keyof NexusGenEnums

export type NexusGenInterfaceNames = keyof NexusGenInterfaces

export type NexusGenScalarNames = keyof NexusGenScalars

export type NexusGenUnionNames = keyof NexusGenUnions

export type NexusGenObjectsUsingAbstractStrategyIsTypeOf = never

export type NexusGenAbstractsUsingStrategyResolveType = 'Character' | 'CharacterUnion'

export type NexusGenFeaturesConfig = {
  abstractTypeStrategies: {
    isTypeOf: false
    resolveType: true
    __typename: false
  }
}

export interface NexusGenTypes {
  context: ContextType
  inputTypes: NexusGenInputs
  rootTypes: NexusGenRootTypes
  inputTypeShapes: NexusGenInputs & NexusGenEnums & NexusGenScalars
  argTypes: NexusGenArgTypes
  fieldTypes: NexusGenFieldTypes
  fieldTypeNames: NexusGenFieldTypeNames
  allTypes: NexusGenAllTypes
  typeInterfaces: NexusGenTypeInterfaces
  objectNames: NexusGenObjectNames
  inputNames: NexusGenInputNames
  enumNames: NexusGenEnumNames
  interfaceNames: NexusGenInterfaceNames
  scalarNames: NexusGenScalarNames
  unionNames: NexusGenUnionNames
  allInputTypes: NexusGenTypes['inputNames'] | NexusGenTypes['enumNames'] | NexusGenTypes['scalarNames']
  allOutputTypes:
    | NexusGenTypes['objectNames']
    | NexusGenTypes['enumNames']
    | NexusGenTypes['unionNames']
    | NexusGenTypes['interfaceNames']
    | NexusGenTypes['scalarNames']
  allNamedTypes: NexusGenTypes['allInputTypes'] | NexusGenTypes['allOutputTypes']
  abstractTypes: NexusGenTypes['interfaceNames'] | NexusGenTypes['unionNames']
  abstractTypeMembers: NexusGenAbstractTypeMembers
  objectsUsingAbstractStrategyIsTypeOf: NexusGenObjectsUsingAbstractStrategyIsTypeOf
  abstractsUsingStrategyResolveType: NexusGenAbstractsUsingStrategyResolveType
  features: NexusGenFeaturesConfig
}

declare global {
  interface NexusGenPluginTypeConfig<TypeName extends string> {}
  interface NexusGenPluginFieldConfig<TypeName extends string, FieldName extends string> {}
  interface NexusGenPluginInputFieldConfig<TypeName extends string, FieldName extends string> {}
  interface NexusGenPluginSchemaConfig {}
  interface NexusGenPluginArgConfig {}
}
