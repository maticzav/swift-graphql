import Foundation
import SwiftGraphQLCodegen

/* Download the schema. */
//let endpoint = URL(string: "http://elm-graphql.herokuapp.com/")!
let endpoint = URL(string: "https://api.graphql.jobs/")!
let dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
let target = dir.appendingPathComponent("API.swift", isDirectory: false)

//GraphQLSchema.downloadFrom(endpoint) { (schema: GraphQL.Schema) in
//    print(schema.objects)
//}


//GraphQLCodegen.generate(from: endpoint) { code in
//    print(code)
//}

//GraphQLCodegen.generate(target, from: endpoint) {
//    print("DONE!")
//}


import SwiftGraphQL

// MARK: - Operations

/* Query */

extension SelectionSet where TypeLock == RootQuery {
    ///
    func jobs<Type>(_ selection: Selection<Type, [JobObject]>) -> Type {
        let field = GraphQLField.composite(name: "jobs", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func job<Type>(_ selection: Selection<Type, JobObject>) -> Type {
        print("JOB")
        print(selection)
        let field = GraphQLField.composite(name: "job", selection: selection.selection)

        // selection
        self.select(field)
        
        print("DECODED")

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! Any))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func locations<Type>(_ selection: Selection<Type, [LocationObject]>) -> Type {
        let field = GraphQLField.composite(name: "locations", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func city<Type>(_ selection: Selection<Type, CityObject>) -> Type {
        let field = GraphQLField.composite(name: "city", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! Any))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func country<Type>(_ selection: Selection<Type, CountryObject>) -> Type {
        let field = GraphQLField.composite(name: "country", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! Any))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func remote<Type>(_ selection: Selection<Type, RemoteObject>) -> Type {
        let field = GraphQLField.composite(name: "remote", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! Any))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func commitments<Type>(_ selection: Selection<Type, [CommitmentObject]>) -> Type {
        let field = GraphQLField.composite(name: "commitments", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func cities<Type>(_ selection: Selection<Type, [CityObject]>) -> Type {
        let field = GraphQLField.composite(name: "cities", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func countries<Type>(_ selection: Selection<Type, [CountryObject]>) -> Type {
        let field = GraphQLField.composite(name: "countries", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func remotes<Type>(_ selection: Selection<Type, [RemoteObject]>) -> Type {
        let field = GraphQLField.composite(name: "remotes", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func companies<Type>(_ selection: Selection<Type, [CompanyObject]>) -> Type {
        let field = GraphQLField.composite(name: "companies", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]))
        }

        // mock placeholder
        return selection.mock()
    }
}
/* Mutation */

extension SelectionSet where TypeLock == RootMutation {
    ///
    func subscribe<Type>(_ selection: Selection<Type, UserObject>) -> Type {
        let field = GraphQLField.composite(name: "subscribe", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! Any))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func postJob<Type>(_ selection: Selection<Type, JobObject>) -> Type {
        let field = GraphQLField.composite(name: "postJob", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! Any))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func updateJob<Type>(_ selection: Selection<Type, JobObject>) -> Type {
        let field = GraphQLField.composite(name: "updateJob", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! Any))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func updateCompany<Type>(_ selection: Selection<Type, CompanyObject>) -> Type {
        let field = GraphQLField.composite(name: "updateCompany", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! Any))
        }

        // mock placeholder
        return selection.mock()
    }
}

// MARK: - Objects

enum Object {
    enum Job {}
    enum Commitment {}
    enum City {}
    enum Country {}
    enum Remote {}
    enum Company {}
    enum Tag {}
    enum Location {}
    enum User {}
}

typealias JobObject = Object.Job
typealias CommitmentObject = Object.Commitment
typealias CityObject = Object.City
typealias CountryObject = Object.Country
typealias RemoteObject = Object.Remote
typealias CompanyObject = Object.Company
typealias TagObject = Object.Tag
typealias LocationObject = Object.Location
typealias UserObject = Object.User

// MARK: - Selection

/* Job */

extension SelectionSet where TypeLock == JobObject {
    ///
    func id() -> String {
        let field = GraphQLField.leaf(name: "id")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "8378"
    }
    ///
    func title() -> String {
        let field = GraphQLField.leaf(name: "title")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func slug() -> String {
        let field = GraphQLField.leaf(name: "slug")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func commitment<Type>(_ selection: Selection<Type, CommitmentObject>) -> Type {
        let field = GraphQLField.composite(name: "commitment", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! Any))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func cities<Type>(_ selection: Selection<Type, [CityObject]?>) -> Type {
        let field = GraphQLField.composite(name: "cities", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]?))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func countries<Type>(_ selection: Selection<Type, [CountryObject]?>) -> Type {
        let field = GraphQLField.composite(name: "countries", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]?))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func remotes<Type>(_ selection: Selection<Type, [RemoteObject]?>) -> Type {
        let field = GraphQLField.composite(name: "remotes", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]?))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func description() -> String? {
        let field = GraphQLField.leaf(name: "description")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String?
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func applyUrl() -> String? {
        let field = GraphQLField.leaf(name: "applyUrl")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String?
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func company<Type>(_ selection: Selection<Type, CompanyObject?>) -> Type {
        let field = GraphQLField.composite(name: "company", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! Any?))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func tags<Type>(_ selection: Selection<Type, [TagObject]?>) -> Type {
        let field = GraphQLField.composite(name: "tags", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]?))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func isPublished() -> Bool? {
        let field = GraphQLField.leaf(name: "isPublished")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! Bool?
        }

        // mock placeholder
        return true
    }
    ///
    func isFeatured() -> Bool? {
        let field = GraphQLField.leaf(name: "isFeatured")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! Bool?
        }

        // mock placeholder
        return true
    }
    ///
    func locationNames() -> String? {
        let field = GraphQLField.leaf(name: "locationNames")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String?
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func userEmail() -> String? {
        let field = GraphQLField.leaf(name: "userEmail")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String?
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
}
/* Commitment */

extension SelectionSet where TypeLock == CommitmentObject {
    ///
    func id() -> String {
        let field = GraphQLField.leaf(name: "id")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "8378"
    }
    ///
    func title() -> String {
        let field = GraphQLField.leaf(name: "title")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func slug() -> String {
        let field = GraphQLField.leaf(name: "slug")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func jobs<Type>(_ selection: Selection<Type, [JobObject]?>) -> Type {
        let field = GraphQLField.composite(name: "jobs", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]?))
        }

        // mock placeholder
        return selection.mock()
    }
}
/* City */

extension SelectionSet where TypeLock == CityObject {
    ///
    func id() -> String {
        let field = GraphQLField.leaf(name: "id")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "8378"
    }
    ///
    func name() -> String {
        let field = GraphQLField.leaf(name: "name")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func slug() -> String {
        let field = GraphQLField.leaf(name: "slug")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func country<Type>(_ selection: Selection<Type, CountryObject>) -> Type {
        let field = GraphQLField.composite(name: "country", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! Any))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func type() -> String {
        let field = GraphQLField.leaf(name: "type")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func jobs<Type>(_ selection: Selection<Type, [JobObject]?>) -> Type {
        let field = GraphQLField.composite(name: "jobs", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]?))
        }

        // mock placeholder
        return selection.mock()
    }
}
/* Country */

extension SelectionSet where TypeLock == CountryObject {
    ///
    func id() -> String {
        let field = GraphQLField.leaf(name: "id")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "8378"
    }
    ///
    func name() -> String {
        let field = GraphQLField.leaf(name: "name")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func slug() -> String {
        let field = GraphQLField.leaf(name: "slug")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func type() -> String {
        let field = GraphQLField.leaf(name: "type")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func isoCode() -> String? {
        let field = GraphQLField.leaf(name: "isoCode")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String?
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func cities<Type>(_ selection: Selection<Type, [CityObject]?>) -> Type {
        let field = GraphQLField.composite(name: "cities", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]?))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func jobs<Type>(_ selection: Selection<Type, [JobObject]?>) -> Type {
        let field = GraphQLField.composite(name: "jobs", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]?))
        }

        // mock placeholder
        return selection.mock()
    }
}
/* Remote */

extension SelectionSet where TypeLock == RemoteObject {
    ///
    func id() -> String {
        let field = GraphQLField.leaf(name: "id")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "8378"
    }
    ///
    func name() -> String {
        let field = GraphQLField.leaf(name: "name")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func slug() -> String {
        let field = GraphQLField.leaf(name: "slug")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func type() -> String {
        let field = GraphQLField.leaf(name: "type")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func jobs<Type>(_ selection: Selection<Type, [JobObject]?>) -> Type {
        let field = GraphQLField.composite(name: "jobs", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]?))
        }

        // mock placeholder
        return selection.mock()
    }
}
/* Company */

extension SelectionSet where TypeLock == CompanyObject {
    ///
    func id() -> String {
        let field = GraphQLField.leaf(name: "id")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "8378"
    }
    ///
    func name() -> String {
        let field = GraphQLField.leaf(name: "name")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func slug() -> String {
        let field = GraphQLField.leaf(name: "slug")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func websiteUrl() -> String {
        let field = GraphQLField.leaf(name: "websiteUrl")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func logoUrl() -> String? {
        let field = GraphQLField.leaf(name: "logoUrl")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String?
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func jobs<Type>(_ selection: Selection<Type, [JobObject]?>) -> Type {
        let field = GraphQLField.composite(name: "jobs", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]?))
        }

        // mock placeholder
        return selection.mock()
    }
    ///
    func twitter() -> String? {
        let field = GraphQLField.leaf(name: "twitter")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String?
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func emailed() -> Bool? {
        let field = GraphQLField.leaf(name: "emailed")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! Bool?
        }

        // mock placeholder
        return true
    }
}
/* Tag */

extension SelectionSet where TypeLock == TagObject {
    ///
    func id() -> String {
        let field = GraphQLField.leaf(name: "id")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "8378"
    }
    ///
    func name() -> String {
        let field = GraphQLField.leaf(name: "name")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func slug() -> String {
        let field = GraphQLField.leaf(name: "slug")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func jobs<Type>(_ selection: Selection<Type, [JobObject]?>) -> Type {
        let field = GraphQLField.composite(name: "jobs", selection: selection.selection)

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any]?))
        }

        // mock placeholder
        return selection.mock()
    }
}
/* Location */

extension SelectionSet where TypeLock == LocationObject {
    ///
    func id() -> String {
        let field = GraphQLField.leaf(name: "id")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "8378"
    }
    ///
    func slug() -> String {
        let field = GraphQLField.leaf(name: "slug")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func name() -> String {
        let field = GraphQLField.leaf(name: "name")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func type() -> String {
        let field = GraphQLField.leaf(name: "type")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
}
/* User */

extension SelectionSet where TypeLock == UserObject {
    ///
    func id() -> String {
        let field = GraphQLField.leaf(name: "id")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "8378"
    }
    ///
    func name() -> String? {
        let field = GraphQLField.leaf(name: "name")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String?
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func email() -> String {
        let field = GraphQLField.leaf(name: "email")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! String
        }

        // mock placeholder
        return "Matic Zavadlal"
    }
    ///
    func subscribe() -> Bool {
        let field = GraphQLField.leaf(name: "subscribe")

        // selection
        self.select(field)

        // decoder
        if let data = self.response {
           return (data as! [String: Any])[field.name] as! Bool
        }

        // mock placeholder
        return true
    }
}

// MARK: - Enums

enum JobOrderByInput: String, CaseIterable, Codable {
    case id_ASC = "id_ASC"
    case id_DESC = "id_DESC"
    case title_ASC = "title_ASC"
    case title_DESC = "title_DESC"
    case slug_ASC = "slug_ASC"
    case slug_DESC = "slug_DESC"
    case description_ASC = "description_ASC"
    case description_DESC = "description_DESC"
    case applyUrl_ASC = "applyUrl_ASC"
    case applyUrl_DESC = "applyUrl_DESC"
    case isPublished_ASC = "isPublished_ASC"
    case isPublished_DESC = "isPublished_DESC"
    case isFeatured_ASC = "isFeatured_ASC"
    case isFeatured_DESC = "isFeatured_DESC"
    case locationNames_ASC = "locationNames_ASC"
    case locationNames_DESC = "locationNames_DESC"
    case userEmail_ASC = "userEmail_ASC"
    case userEmail_DESC = "userEmail_DESC"
    case postedAt_ASC = "postedAt_ASC"
    case postedAt_DESC = "postedAt_DESC"
    case createdAt_ASC = "createdAt_ASC"
    case createdAt_DESC = "createdAt_DESC"
    case updatedAt_ASC = "updatedAt_ASC"
    case updatedAt_DESC = "updatedAt_DESC"
}
enum CityOrderByInput: String, CaseIterable, Codable {
    case id_ASC = "id_ASC"
    case id_DESC = "id_DESC"
    case name_ASC = "name_ASC"
    case name_DESC = "name_DESC"
    case slug_ASC = "slug_ASC"
    case slug_DESC = "slug_DESC"
    case type_ASC = "type_ASC"
    case type_DESC = "type_DESC"
    case createdAt_ASC = "createdAt_ASC"
    case createdAt_DESC = "createdAt_DESC"
    case updatedAt_ASC = "updatedAt_ASC"
    case updatedAt_DESC = "updatedAt_DESC"
}
enum CountryOrderByInput: String, CaseIterable, Codable {
    case id_ASC = "id_ASC"
    case id_DESC = "id_DESC"
    case name_ASC = "name_ASC"
    case name_DESC = "name_DESC"
    case slug_ASC = "slug_ASC"
    case slug_DESC = "slug_DESC"
    case type_ASC = "type_ASC"
    case type_DESC = "type_DESC"
    case isoCode_ASC = "isoCode_ASC"
    case isoCode_DESC = "isoCode_DESC"
    case createdAt_ASC = "createdAt_ASC"
    case createdAt_DESC = "createdAt_DESC"
    case updatedAt_ASC = "updatedAt_ASC"
    case updatedAt_DESC = "updatedAt_DESC"
}
enum RemoteOrderByInput: String, CaseIterable, Codable {
    case id_ASC = "id_ASC"
    case id_DESC = "id_DESC"
    case name_ASC = "name_ASC"
    case name_DESC = "name_DESC"
    case slug_ASC = "slug_ASC"
    case slug_DESC = "slug_DESC"
    case type_ASC = "type_ASC"
    case type_DESC = "type_DESC"
    case createdAt_ASC = "createdAt_ASC"
    case createdAt_DESC = "createdAt_DESC"
    case updatedAt_ASC = "updatedAt_ASC"
    case updatedAt_DESC = "updatedAt_DESC"
}
enum TagOrderByInput: String, CaseIterable, Codable {
    case id_ASC = "id_ASC"
    case id_DESC = "id_DESC"
    case name_ASC = "name_ASC"
    case name_DESC = "name_DESC"
    case slug_ASC = "slug_ASC"
    case slug_DESC = "slug_DESC"
    case createdAt_ASC = "createdAt_ASC"
    case createdAt_DESC = "createdAt_DESC"
    case updatedAt_ASC = "updatedAt_ASC"
    case updatedAt_DESC = "updatedAt_DESC"
}


/* Experimenting */


struct Job {
    let id: String
    let name: String
}

let job = Selection<Job, JobObject> {
    Job(
        id: $0.id(),
        name: $0.title()
    )
}

struct City {
    let id: String
    let name: String
    let slug: String
}

let city = Selection<City, CityObject> {
    City(id: $0.id(), name: $0.name(), slug: $0.slug())
}

let query = Selection<String, RootQuery> {
    let jobs = $0.jobs(job.list)
    let _ = $0.cities(city.list)
    return jobs.map { $0.name }.joined()
}



print(GraphQLClient.serialize(selection: query))
