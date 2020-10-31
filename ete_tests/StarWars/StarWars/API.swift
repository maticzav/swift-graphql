import SwiftGraphQL

// MARK: - Operations

enum Operations {}

/* Query */

extension Operations {
    struct Query: GraphQLRootQuery, Encodable {
    
        /* Query */
    
        /* Properties */
        let human: [String: Objects.Human]
        let droid: [String: Objects.Droid]
        let character: [String: Unions.CharacterUnion]
        let humans: [String: [Objects.Human]]
        let droids: [String: [Objects.Droid]]
        let characters: [String: [Interfaces.Character]]
        let greeting: [String: String]
        let time: [String: DateTime]
    }
}
extension Operations.Query: Decodable {

/* Decoder */
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)


    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
            case "human":
                if let value = try container.decode(Objects.Human?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "droid":
                if let value = try container.decode(Objects.Droid?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "character":
                if let value = try container.decode(Unions.CharacterUnion?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "humans":
                if let value = try container.decode([Objects.Human]?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "droids":
                if let value = try container.decode([Objects.Droid]?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "characters":
                if let value = try container.decode([Interfaces.Character]?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "greeting":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "time":
                if let value = try container.decode(DateTime?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unknown key \(field)."
                    )
                )
        }
    }

    self.human = map["human"]
    self.droid = map["droid"]
    self.character = map["character"]
    self.humans = map["humans"]
    self.droids = map["droids"]
    self.characters = map["characters"]
    self.greeting = map["greeting"]
    self.time = map["time"]
}

    private struct DynamicCodingKeys: CodingKey {
        // Use for string-keyed dictionary
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
    
        // Use for integer-keyed dictionary
        var intValue: Int?
        init?(intValue: Int) { nil }
    }
}

extension SelectionSet where TypeLock == Operations.Query {
    func human<Type>(id: String, _ selection: Selection<Type, Objects.Human?>) -> Type {
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
            return data.human[field.alias!].map { selection.decode(data: $0) } ?? selection.mock()
        }
        return selection.mock()
    }
    func droid<Type>(id: String, _ selection: Selection<Type, Objects.Droid?>) -> Type {
        /* Selection */
        let field = GraphQLField.composite(
            name: "droid",
            arguments: [
                Argument(name: "id", type: "ID!", value: id),
            ],
            selection: selection.selection
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.droid[field.alias!].map { selection.decode(data: $0) } ?? selection.mock()
        }
        return selection.mock()
    }
    func character<Type>(id: String, _ selection: Selection<Type, Unions.CharacterUnion?>) -> Type {
        /* Selection */
        let field = GraphQLField.composite(
            name: "character",
            arguments: [
                Argument(name: "id", type: "ID!", value: id),
            ],
            selection: selection.selection
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.character[field.alias!].map { selection.decode(data: $0) } ?? selection.mock()
        }
        return selection.mock()
    }
    func humans<Type>(_ selection: Selection<Type, [Objects.Human]>) -> Type {
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
            return selection.decode(data: data.humans[field.alias!]!)
        }
        return selection.mock()
    }
    func droids<Type>(_ selection: Selection<Type, [Objects.Droid]>) -> Type {
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
            return selection.decode(data: data.droids[field.alias!]!)
        }
        return selection.mock()
    }
    func characters<Type>(_ selection: Selection<Type, [Interfaces.Character]>) -> Type {
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
            return selection.decode(data: data.characters[field.alias!]!)
        }
        return selection.mock()
    }
    func greeting(input: OptionalArgument<InputObjects.Greeting> = .absent) -> String {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "greeting",
            arguments: [
                Argument(name: "input", type: "Greeting", value: input),
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.greeting[field.alias!]!
        }
        return String.mockValue
    }
    func time() -> DateTime {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "time",
            arguments: [
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.time[field.alias!]!
        }
        return DateTime.mockValue
    }
}

// MARK: - Objects

enum Objects {}

/* Droid */

extension Objects {
    struct Droid: Encodable {
    
        /* Droid */
    
        /* Properties */
        let id: [String: String]
        let name: [String: String]
        let primaryFunction: [String: String]
        let appearsIn: [String: [Enums.Episode]]
    }
}
extension Objects.Droid: Decodable {

/* Decoder */
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)


    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
            case "id":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "name":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "primaryFunction":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "appearsIn":
                if let value = try container.decode([Enums.Episode]?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unknown key \(field)."
                    )
                )
        }
    }

    self.id = map["id"]
    self.name = map["name"]
    self.primaryFunction = map["primaryFunction"]
    self.appearsIn = map["appearsIn"]
}

    private struct DynamicCodingKeys: CodingKey {
        // Use for string-keyed dictionary
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
    
        // Use for integer-keyed dictionary
        var intValue: Int?
        init?(intValue: Int) { nil }
    }
}

extension SelectionSet where TypeLock == Objects.Droid {
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
            return data.id[field.alias!]!
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
            return data.name[field.alias!]!
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
            return data.primaryFunction[field.alias!]!
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
            return data.appearsIn[field.alias!]!
        }
        return []
    }
}


/* Human */

extension Objects {
    struct Human: Encodable {
    
        /* Human */
    
        /* Properties */
        let id: [String: String]
        let name: [String: String]
        let homePlanet: [String: String]
        let appearsIn: [String: [Enums.Episode]]
    }
}
extension Objects.Human: Decodable {

/* Decoder */
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)


    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
            case "id":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "name":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "homePlanet":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "appearsIn":
                if let value = try container.decode([Enums.Episode]?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unknown key \(field)."
                    )
                )
        }
    }

    self.id = map["id"]
    self.name = map["name"]
    self.homePlanet = map["homePlanet"]
    self.appearsIn = map["appearsIn"]
}

    private struct DynamicCodingKeys: CodingKey {
        // Use for string-keyed dictionary
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
    
        // Use for integer-keyed dictionary
        var intValue: Int?
        init?(intValue: Int) { nil }
    }
}

extension SelectionSet where TypeLock == Objects.Human {
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
            return data.id[field.alias!]!
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
            return data.name[field.alias!]!
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
            return data.homePlanet[field.alias!]
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
            return data.appearsIn[field.alias!]!
        }
        return []
    }
}

// MARK: - Interfaces

enum Interfaces {}

/* Character */

extension Interfaces {
    struct Character: Encodable {
    
        /* Character */
        enum TypeName: String, Codable {
            case droid = "Droid"
            case human = "Human"
        }
    
        /* Properties */
        let __typename: TypeName
        let id: [String: String]
        let name: [String: String]
        let primaryFunction: [String: String]
        let appearsIn: [String: [Enums.Episode]]
        let homePlanet: [String: String]
    }
}

extension Interfaces.Character: Decodable {

/* Decoder */
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)


    var map = HashMap()
    for codingKey in container.allKeys {
        if codingKey.isTypenameKey { continue }

        let alias = codingKey.stringValue
        let field = GraphQLField.getFieldNameFromAlias(alias)

        switch field {
            case "id":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "name":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "primaryFunction":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "appearsIn":
                if let value = try container.decode([Enums.Episode]?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "homePlanet":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unknown key \(field)."
                    )
                )
        }
    }

    self.__typename = try container.decode(TypeName.self, forKey: DynamicCodingKeys(stringValue: "__typename")!)
    self.id = map["id"]
    self.name = map["name"]
    self.primaryFunction = map["primaryFunction"]
    self.appearsIn = map["appearsIn"]
    self.homePlanet = map["homePlanet"]
}

    private struct DynamicCodingKeys: CodingKey {
        // Use for string-keyed dictionary
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
    
        // Use for integer-keyed dictionary
        var intValue: Int?
        init?(intValue: Int) { nil }
    }
}

extension SelectionSet where TypeLock == Interfaces.Character {
    /// The id of the character
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
            return data.id[field.alias!]!
        }
        return String.mockValue
    }
    /// The name of the character
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
            return data.name[field.alias!]!
        }
        return String.mockValue
    }
}

extension SelectionSet where TypeLock == Interfaces.Character {
    func on<Type>(
        droid: Selection<Type, Objects.Droid>,
        human: Selection<Type, Objects.Human>
    ) -> Type {
        /* Selection */
        self.select([
            GraphQLField.fragment(type: "Droid", selection: droid.selection),
            GraphQLField.fragment(type: "Human", selection: human.selection),
        ])
        /* Decoder */
        if let data = self.response {
            switch data.__typename {
            case .droid:
                let data = Objects.Droid(
                    id: data.id,
                    name: data.name,
                    primaryFunction: data.primaryFunction,
                    appearsIn: data.appearsIn
                )
                return droid.decode(data: data)
            case .human:
                let data = Objects.Human(
                    id: data.id,
                    name: data.name,
                    homePlanet: data.homePlanet,
                    appearsIn: data.appearsIn
                )
                return human.decode(data: data)
            }
        }
        
        return droid.mock()
    }
}

// MARK: - Unions

enum Unions {}

/* CharacterUnion */

extension Unions {
    struct CharacterUnion: Encodable {
    
        /* CharacterUnion */
        enum TypeName: String, Codable {
            case human = "Human"
            case droid = "Droid"
        }
    
        /* Properties */
        let __typename: TypeName
        let id: [String: String]
        let name: [String: String]
        let primaryFunction: [String: String]
        let appearsIn: [String: [Enums.Episode]]
        let homePlanet: [String: String]
    }
}

extension Unions.CharacterUnion: Decodable {
    
    /* Decoder */
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
    
    
        var map = HashMap()
        for codingKey in container.allKeys {
            if codingKey.isTypenameKey { continue }
    
            let alias = codingKey.stringValue
            let field = GraphQLField.getFieldNameFromAlias(alias)
    
            switch field {
                case "id":
                    if let value = try container.decode(String?.self, forKey: codingKey) {
                        map.set(key: field, hash: alias, value: value as Any)
                    }
                case "name":
                    if let value = try container.decode(String?.self, forKey: codingKey) {
                        map.set(key: field, hash: alias, value: value as Any)
                    }
                case "primaryFunction":
                    if let value = try container.decode(String?.self, forKey: codingKey) {
                        map.set(key: field, hash: alias, value: value as Any)
                    }
                case "appearsIn":
                    if let value = try container.decode([Enums.Episode]?.self, forKey: codingKey) {
                        map.set(key: field, hash: alias, value: value as Any)
                    }
                case "homePlanet":
                    if let value = try container.decode(String?.self, forKey: codingKey) {
                        map.set(key: field, hash: alias, value: value as Any)
                    }
                default:
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Unknown key \(field)."
                        )
                    )
            }
        }
    
        self.__typename = try container.decode(TypeName.self, forKey: DynamicCodingKeys(stringValue: "__typename")!)
        self.id = map["id"]
        self.name = map["name"]
        self.primaryFunction = map["primaryFunction"]
        self.appearsIn = map["appearsIn"]
        self.homePlanet = map["homePlanet"]
    }
    
        private struct DynamicCodingKeys: CodingKey {
            // Use for string-keyed dictionary
            var stringValue: String
            init?(stringValue: String) {
                self.stringValue = stringValue
            }
        
            // Use for integer-keyed dictionary
            var intValue: Int?
            init?(intValue: Int) { nil }
        }
}

extension SelectionSet where TypeLock == Unions.CharacterUnion {
    func on<Type>(
        human: Selection<Type, Objects.Human>,
        droid: Selection<Type, Objects.Droid>
    ) -> Type {
        /* Selection */
        self.select([
            GraphQLField.fragment(type: "Human", selection: human.selection),
            GraphQLField.fragment(type: "Droid", selection: droid.selection),
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
        
        return human.mock()
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
    struct Greeting: Encodable, Hashable {
        var language: OptionalArgument<Enums.Language> = .absent
        var name: String
    
        /* Encoder */
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
        
            if language.hasValue { try container.encode(language, forKey: .language) }
            try container.encode(name, forKey: .name)
        }
    
        /* CodingKeys */
        enum CodingKeys: CodingKey {
            case language
            case name
        }
    }


    struct GreetingOptions: Encodable, Hashable {
        var prefix: OptionalArgument<String> = .absent
    
        /* Encoder */
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
        
            if prefix.hasValue { try container.encode(prefix, forKey: .prefix) }
        }
    
        /* CodingKeys */
        enum CodingKeys: CodingKey {
            case prefix
        }
    }
}