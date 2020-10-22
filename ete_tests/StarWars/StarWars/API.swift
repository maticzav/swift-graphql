import SwiftGraphQL

// MARK: - Operations

/* Query */

//extension SelectionSet where TypeLock == RootQuery {
//    func human<Type>(id: ID, _ selection: Selection<Type, HumanObject?>) -> Type {
//        /* Selection */
//        let field = GraphQLField.composite(
//            name: "human",
//            arguments: [
//                Argument(name: "id", value: ),
//            ],
//            selection: selection.selection
//        )
//        self.select(field)
//
//        /* Decoder */
//        if let data = self.response as? [String: Any] {
//            return (data[field.name] as! Any?).map { selection.decode(data: $0) } ?? selection.mock()
//        }
//        return selection.mock()
//    }
//
//    func droid<Type>(id: ID, _ selection: Selection<Type, DroidObject>) -> Type {
//        /* Selection */
//        let field = GraphQLField.composite(
//            name: "droid",
//            arguments: [
//                Argument(name: "id", value: ),
//            ],
//            selection: selection.selection
//        )
//        self.select(field)
//
//        /* Decoder */
//        if let data = self.response as? [String: Any] {
//            return selection.decode(data: (data[field.name] as! Any))
//        }
//        return selection.mock()
//    }
//
//    func humans<Type>(_ selection: Selection<Type, [HumanObject?]>) -> Type {
//        /* Selection */
//        let field = GraphQLField.composite(
//            name: "humans",
//            arguments: [
//
//            ],
//            selection: selection.selection
//        )
//        self.select(field)
//
//        /* Decoder */
//        if let data = self.response as? [String: Any] {
//            return selection.decode(data: (data[field.name] as! [Any?]))
//        }
//        return selection.mock()
//    }
//}
//
//// MARK: - Objects
//
//enum Object {
//    enum Droid {}
//    enum Human {}
//    enum Query {}
//}
//
//typealias DroidObject = Object.Droid
//typealias HumanObject = Object.Human
//typealias QueryObject = Object.Query
//
//// MARK: - Selection
//
///* Droid */
//
//extension SelectionSet where TypeLock == DroidObject {
//    /// The id of the character
//    func id() -> String {
//        /* Selection */
//        let field = GraphQLField.leaf(
//            name: "id",
//            arguments: [
//
//            ]
//        )
//        self.select(field)
//
//        /* Decoder */
//        if let data = self.response as? [String: Any] {
//            return data[field.name] as! String
//        }
//        return
//    }
//
//    /// The name of the character
//    func name() -> String {
//        /* Selection */
//        let field = GraphQLField.leaf(
//            name: "name",
//            arguments: [
//
//            ]
//        )
//        self.select(field)
//
//        /* Decoder */
//        if let data = self.response as? [String: Any] {
//            return data[field.name] as! String
//        }
//        return
//    }
//
//    /// Which movies they appear in.
//    func appearsin(id: ID) -> [Episode?] {
//        /* Selection */
//        let field = GraphQLField.leaf(
//            name: "appearsIn",
//            arguments: [
//                Argument(name: "id", value: ),
//            ]
//        )
//        self.select(field)
//
//        /* Decoder */
//        if let data = self.response as? [String: Any] {
//            return (data[field.name] as! [String?]).map { $0.map { Episode.init(rawValue: $0)! } }
//        }
//        return []
//    }
//
//    /// The primary function of the droid.
//    func primaryfunction() -> String {
//        /* Selection */
//        let field = GraphQLField.leaf(
//            name: "primaryFunction",
//            arguments: [
//
//            ]
//        )
//        self.select(field)
//
//        /* Decoder */
//        if let data = self.response as? [String: Any] {
//            return data[field.name] as! String
//        }
//        return
//    }
//}
//
//
///* Human */
//
//extension SelectionSet where TypeLock == HumanObject {
//    /// The id of the character
//    func id() -> String {
//        /* Selection */
//        let field = GraphQLField.leaf(
//            name: "id",
//            arguments: [
//
//            ]
//        )
//        self.select(field)
//
//        /* Decoder */
//        if let data = self.response as? [String: Any] {
//            return data[field.name] as! String
//        }
//        return
//    }
//
//    /// The name of the character
//    func name() -> String {
//        /* Selection */
//        let field = GraphQLField.leaf(
//            name: "name",
//            arguments: [
//
//            ]
//        )
//        self.select(field)
//
//        /* Decoder */
//        if let data = self.response as? [String: Any] {
//            return data[field.name] as! String
//        }
//        return
//    }
//
//    /// Which movies they appear in.
//    func appearsin(id: ID) -> [Episode?] {
//        /* Selection */
//        let field = GraphQLField.leaf(
//            name: "appearsIn",
//            arguments: [
//                Argument(name: "id", value: ),
//            ]
//        )
//        self.select(field)
//
//        /* Decoder */
//        if let data = self.response as? [String: Any] {
//            return (data[field.name] as! [String?]).map { $0.map { Episode.init(rawValue: $0)! } }
//        }
//        return []
//    }
//
//    /// The home planet of the human, or null if unknown.
//    func homeplanet() -> String? {
//        /* Selection */
//        let field = GraphQLField.leaf(
//            name: "homePlanet",
//            arguments: [
//
//            ]
//        )
//        self.select(field)
//
//        /* Decoder */
//        if let data = self.response as? [String: Any] {
//            return data[field.name] as! String?
//        }
//        return
//    }
//}
//
//// MARK: - Enums
//
///// One of the films in the Star Wars Trilogy
//enum Episode: String, CaseIterable, Codable {
//    /// Released in 1977.
//    case newhope = "NEWHOPE"
//
//    /// Released in 1980.
//    case empire = "EMPIRE"
//
//    /// Released in 1983
//    case jedi = "JEDI"
//}
//
//
///// MoreEpisodes
//enum MoreEpisodes: String, CaseIterable, Codable {
//    /// Released in 1977.
//    case newhope = "NEWHOPE"
//
//    /// Released in 1980.
//    case empire = "EMPIRE"
//
//    /// Released in 1983
//    case jedi = "JEDI"
//
//    case other = "OTHER"
//}
