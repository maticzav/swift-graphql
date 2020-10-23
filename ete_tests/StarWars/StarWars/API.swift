import SwiftGraphQL

enum Objects {}

// MARK: - Operations

/* Query */

extension Objects {
    struct Query: Codable {
        let human: Human?
        let test: [String?]?
        let humans: [Human?]?
    }
}

typealias RootQuery = Objects.Query

extension SelectionSet where TypeLock == RootQuery {
    func human<Type>(id: String, _ selection: Selection<Type, HumanObject?>) -> Type {
        /* Selection */
        let field = GraphQLField.composite(
            name: "human",
            arguments: [
                Argument(name: "id", value: id),
            ],
            selection: selection.selection
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.human.map { selection.decode(data: $0) } ?? selection.mock()
        }
        return selection.mock()
    }

    func test() -> [String?]? {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "test",
            arguments: [
        
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.test
        }
        return nil
    }

    func humans<Type>(_ selection: Selection<Type, [HumanObject?]?>) -> Type {
        /* Selection */
        let field = GraphQLField.composite(
            name: "humans",
            arguments: [
        
            ],
            selection: selection.selection
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.humans.map { selection.decode(data: $0) } ?? selection.mock()
        }
        return selection.mock()
    }
}

// MARK: - Selection

/* Human */

extension Objects {
    struct Human: Codable {
        let id: String?
        let name: String?
        let homePlanet: String?
        let appearsIn: [Episode?]?
    }
}

typealias HumanObject = Objects.Human

extension SelectionSet where TypeLock == HumanObject {
    func id() -> String? {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "id",
            arguments: [
        
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.id
        }
        return nil
    }

    func name() -> String? {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "name",
            arguments: [
        
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.name
        }
        return nil
    }

    /// The home planet of the human, or null if unknown.
    func homeplanet() -> String? {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "homePlanet",
            arguments: [
        
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.homePlanet
        }
        return nil
    }

    func appearsin() -> [Episode?]? {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "appearsIn",
            arguments: [
        
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.appearsIn
        }
        return nil
    }
}

// MARK: - Enums

/// One of the films in the Star Wars Trilogy
enum Episode: String, CaseIterable, Codable {
    /// Released in 1977.
    case newhope = "NEWHOPE"

    /// Released in 1980.
    case empire = "EMPIRE"

    /// Released in 1983
    case jedi = "JEDI"
}