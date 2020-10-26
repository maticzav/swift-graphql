import SwiftGraphQL

enum Objects {}

// MARK: - Operations

/* Query */

extension Objects {
    struct Query: Codable {
        let human: Human?
        let humans: [Human]?
        let greeting: String?
    }
}

typealias RootQuery = Objects.Query

extension SelectionSet where TypeLock == RootQuery {
    func human<Type>(id: String, _ selection: Selection<Type, HumanObject?>) -> Type {
        /* Selection */
        let field = GraphQLField.composite(
            name: "human",
            arguments: [
                Argument(name: "id", type: "ID!", value: id),
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
    func humans<Type>(_ selection: Selection<Type, [HumanObject]>) -> Type {
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
            return selection.decode(data: data.humans!)
        }
        return selection.mock()
    }
    func greeting(input: InputObjects.Greeting) -> String {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "greeting",
            arguments: [
                Argument(name: "input", type: "Greeting!", value: input),
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.greeting!
        }
        return String.mockValue
    }
}

// MARK: - Objects

/* Human */

extension Objects {
    struct Human: Codable {
        let id: String?
        let name: String?
        let homePlanet: String?
        let appearsIn: [Enums.Episode]?
    }
}

typealias HumanObject = Objects.Human

extension SelectionSet where TypeLock == HumanObject {
    func id() -> String {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "id",
            arguments: [
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.id!
        }
        return String.mockValue
    }
    func name() -> String {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "name",
            arguments: [
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.name!
        }
        return String.mockValue
    }
    /// The home planet of the human, or null if unknown.
    func homePlanet() -> String? {
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
    func appearsIn() -> [Enums.Episode] {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "appearsIn",
            arguments: [
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.appearsIn!
        }
        return []
    }
}

// MARK: - Enums

enum Enums {
    /// One of the films in the Star Wars Trilogy
    enum Episode: String, CaseIterable, Codable {
        /// Released in 1977.
        case newhope = "NEWHOPE"
        
        /// Released in 1980.
        case empire = "EMPIRE"
        
        /// Released in 1983
        case jedi = "JEDI"
        
    }


    /// Language
    enum Language: String, CaseIterable, Codable {
        case en = "EN"
        
        case sl = "SL"
        
    }
}

// MARK: - Input Objects

enum InputObjects {
    struct Greeting: Codable {
        let language: Enums.Language?
        let name: String
    }


    struct GreetingOptions: Codable {
        let prefix: String?
    }
}