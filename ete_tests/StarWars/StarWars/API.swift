import SwiftGraphQL

enum Objects {}

// MARK: - Operations

/* Query */

extension Objects {
    struct Query: GraphQLRootQuery, Codable {
        let human: Human?
        let humans: [Human]?
        let droids: [Droid]?
        let characters: [Character]?
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
    func droids<Type>(_ selection: Selection<Type, [DroidObject]>) -> Type {
        /* Selection */
        let field = GraphQLField.composite(
            name: "droids",
            arguments: [
            ],
            selection: selection.selection
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return selection.decode(data: data.droids!)
        }
        return selection.mock()
    }
    func characters<Type>(_ selection: Selection<Type, [CharacterObject]>) -> Type {
        /* Selection */
        let field = GraphQLField.composite(
            name: "characters",
            arguments: [
            ],
            selection: selection.selection
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return selection.decode(data: data.characters!)
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

/* Droid */

extension Objects {
    struct Droid: CharacterProtocol, Codable {
        let id: String?
        let name: String?
        let primaryFunction: String?
        let appearsIn: [Enums.Episode]?
    }
}

typealias DroidObject = Objects.Droid

extension SelectionSet where TypeLock == DroidObject {
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
    func primaryFunction() -> String {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "primaryFunction",
            arguments: [
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.primaryFunction!
        }
        return String.mockValue
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


/* Human */

extension Objects {
    struct Human: CharacterProtocol, Codable {
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

protocol CharacterProtocol {
    var id: String? { get }
    var name: String? { get }
}

extension Objects {
    struct Character: CharacterProtocol, Codable {
        let __typename: TypeName
        let id: String?
        let name: String?
        // This type should pack all fields that interface implementations have.
        let primaryFunction: String?
        let homePlanet: String?
        let appearsIn: [Enums.Episode]?
        
        enum TypeName: String, Codable {
            case human = "Human"
            case droid = "Droid"
        }
    }
}

typealias CharacterObject = Objects.Character

/* Fields */
extension SelectionSet where TypeLock == CharacterObject {
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
}

extension SelectionSet where TypeLock == CharacterObject {
    func on<Type>(
        droid: Selection<Type, DroidObject>,
        human: Selection<Type, HumanObject>
    ) -> Type {
        /* Selection */
        self.select([
            GraphQLField.fragment(
                type: "Droid",
                selection: droid.selection
            ),
            GraphQLField.fragment(
                type: "Human",
                selection: human.selection
            )
        ])
        
        /* Decoder */
        if let data = self.response {
            switch data.__typename {
            case .human:
                let data = Objects.Human(
                    id: data.id,
                    name: data.name,
                    homePlanet: data.homePlanet,
                    appearsIn: data.appearsIn
                )
                return human.decode(data: data)
            case .droid:
                let data = Objects.Droid(
                    id: data.id,
                    name: data.name,
                    primaryFunction: data.primaryFunction,
                    appearsIn: data.appearsIn
                )
                return droid.decode(data: data)
            }
        }
        
        return droid.mock()
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
    struct Greeting: Codable, Hashable {
        let language: Enums.Language?
        let name: String
    }


    struct GreetingOptions: Codable, Hashable {
        let prefix: String?
    }
}
