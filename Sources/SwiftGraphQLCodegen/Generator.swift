//
//  File.swift
//  
//
//  Created by Matic Zavadlal on 10/10/2020.
//

import Foundation
import GraphQL


/// Generates the code that can be used to define selections.
func generate(for schema: GraphQLSchema) -> String {
    let types = schema.typeMap.keys
    
    return """
    // MARK: - Operations

    

    // MARK: - Objects

    enum Object {

    }

    // MARK: - Enums

    // MARK: -
    """
}


//func generateEnum(<#parameters#>) -> <#return type#> {
//    <#function body#>
//}


/*
    type Query {
        users: [User!]!
    }
 
    type User {
        id: ID!
        name: String!
        picture: String
        age: Int

        vehicle: Vehicle
        pet: Pet
    }
 
    type Pet {
        id: ID!
        name: String!
        type: PetType
    }
     
 
     enum Vehicle {
         CAR
         BIKE
         BUS
     }
 
    enum PetType {
        CAT
        DOG
        OTHER
    }
 */


// MARK: - Generated

/*
 1. In general it is always so that you should create phantom types for every object, union... - generally anything
     that has some form of a selection set - and extend the selection set afterwards.
 2. The return type of every selector is a generic "Type". We modify the return type in case it is nullable or list.
 */



// Operations

extension SelectionSet where TypeLock == RootQuery {
    func users<Type>(_ selection: SelectionSet<Type, UserObject>) -> [Type] {
        let field = GraphQLField.leaf(name: "users")
        
        if let data = self.data {
            return (data[field.name] as! [Any]).map { selection.decode(data: $0) }
        }
        
        return []
    }
}




// Objects (might be good to extract to a separate file to prevent circular imports)

enum Object {
    enum User {}
    enum Pet {}
}

typealias UserObject = Object.User
typealias PetObject = Object.Pet


// Enums (might be a separate file or folder
// most of what elm-graphql is doing by hand Swift has prebuilt
// (decoding from string, encoding to string, all cases)


enum Vehicle: String, CaseIterable {
    case car = "CAR"
    case bike = "BIKE"
    case bus = "BUS"
}

enum PetType: String, CaseIterable {
    case cat = "CAT"
    case dog = "DOG"
    case other = "OTHER"
}


// SeleectionSet

extension SelectionSet where TypeLock == UserObject {
    /* Fields */
    
    /// Description of the funciton taken from the GraphQL docs.
    func id() -> String {
        let field = GraphQLField.leaf(name: "id")
        
        if let data = self.data {
            return data[field.name] as! String
        }
        
        return "String"
    }
    
    /// Description of the funciton taken from the GraphQL docs.
    func name() -> String {
        let field = GraphQLField.leaf(name: "name")
        
        if let data = self.data {
            return data[field.name] as! String
        }
        
        return "String"
    }
    
    /// Description of the funciton taken from the GraphQL docs.
    func picture() -> String? {
        let field = GraphQLField.leaf(name: "picture")
        
        if let data = self.data {
            return data[field.name] as! String?
        }
        
        return nil
    }
    
    
}




/* Usage. */


