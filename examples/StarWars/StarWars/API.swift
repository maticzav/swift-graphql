import SwiftGraphQL

// MARK: - Operations

enum Operations {}
extension Objects.Query: GraphQLHttpOperation {
    static var operation: String { "query" }
}

extension Objects.Mutation: GraphQLHttpOperation {
    static var operation: String { "mutation" }
}

extension Objects.Subscription: GraphQLWebSocketOperation {
    static var operation: String { "subscription" }
}

// MARK: - Objects

enum Objects {}
extension Objects {
    struct Mutation {
        let __typename: TypeName = .mutation
        let mutate: [String: Bool]

        enum TypeName: String, Codable {
            case mutation = "Mutation"
        }
    }
}

extension Objects.Mutation: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var map = HashMap()
        for codingKey in container.allKeys {
            if codingKey.isTypenameKey { continue }

            let alias = codingKey.stringValue
            let field = GraphQLField.getFieldNameFromAlias(alias)

            switch field {
            case "mutate":
                if let value = try container.decode(Bool?.self, forKey: codingKey) {
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

        mutate = map["mutate"]
    }
}

extension Fields where TypeLock == Objects.Mutation {
    func mutate() throws -> Bool {
        let field = GraphQLField.leaf(
            name: "mutate",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.mutate[field.alias!] {
                return data
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return Bool.mockValue
        }
    }
}

extension Selection where TypeLock == Never, Type == Never {
    typealias Mutation<T> = Selection<T, Objects.Mutation>
}

extension Objects {
    struct Droid {
        let __typename: TypeName = .droid
        let appearsIn: [String: [Enums.Episode]]
        let id: [String: String]
        let name: [String: String]
        let primaryFunction: [String: String]

        enum TypeName: String, Codable {
            case droid = "Droid"
        }
    }
}

extension Objects.Droid: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var map = HashMap()
        for codingKey in container.allKeys {
            if codingKey.isTypenameKey { continue }

            let alias = codingKey.stringValue
            let field = GraphQLField.getFieldNameFromAlias(alias)

            switch field {
            case "name":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "id":
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

        name = map["name"]
        id = map["id"]
        primaryFunction = map["primaryFunction"]
        appearsIn = map["appearsIn"]
    }
}

extension Fields where TypeLock == Objects.Droid {
    func id() throws -> String {
        let field = GraphQLField.leaf(
            name: "id",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.id[field.alias!] {
                return data
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return String.mockValue
        }
    }

    func name() throws -> String {
        let field = GraphQLField.leaf(
            name: "name",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.name[field.alias!] {
                return data
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return String.mockValue
        }
    }

    func primaryFunction() throws -> String {
        let field = GraphQLField.leaf(
            name: "primaryFunction",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.primaryFunction[field.alias!] {
                return data
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return String.mockValue
        }
    }

    func appearsIn() throws -> [Enums.Episode] {
        let field = GraphQLField.leaf(
            name: "appearsIn",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.appearsIn[field.alias!] {
                return data
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return []
        }
    }
}

extension Selection where TypeLock == Never, Type == Never {
    typealias Droid<T> = Selection<T, Objects.Droid>
}

extension Objects {
    struct Human {
        let __typename: TypeName = .human
        let appearsIn: [String: [Enums.Episode]]
        let homePlanet: [String: String]
        let id: [String: String]
        let infoUrl: [String: String]
        let name: [String: String]

        enum TypeName: String, Codable {
            case human = "Human"
        }
    }
}

extension Objects.Human: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var map = HashMap()
        for codingKey in container.allKeys {
            if codingKey.isTypenameKey { continue }

            let alias = codingKey.stringValue
            let field = GraphQLField.getFieldNameFromAlias(alias)

            switch field {
            case "infoUrl":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "name":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "id":
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

        infoUrl = map["infoUrl"]
        name = map["name"]
        id = map["id"]
        homePlanet = map["homePlanet"]
        appearsIn = map["appearsIn"]
    }
}

extension Fields where TypeLock == Objects.Human {
    func id() throws -> String {
        let field = GraphQLField.leaf(
            name: "id",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.id[field.alias!] {
                return data
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return String.mockValue
        }
    }

    func name() throws -> String {
        let field = GraphQLField.leaf(
            name: "name",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.name[field.alias!] {
                return data
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return String.mockValue
        }
    }

    /// The home planet of the human, or null if unknown.

    func homePlanet() throws -> String? {
        let field = GraphQLField.leaf(
            name: "homePlanet",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            return data.homePlanet[field.alias!]
        case .mocking:
            return nil
        }
    }

    func appearsIn() throws -> [Enums.Episode] {
        let field = GraphQLField.leaf(
            name: "appearsIn",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.appearsIn[field.alias!] {
                return data
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return []
        }
    }

    func infoUrl() throws -> String? {
        let field = GraphQLField.leaf(
            name: "infoURL",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            return data.infoUrl[field.alias!]
        case .mocking:
            return nil
        }
    }
}

extension Selection where TypeLock == Never, Type == Never {
    typealias Human<T> = Selection<T, Objects.Human>
}

extension Objects {
    struct Query {
        let __typename: TypeName = .query
        let character: [String: Unions.CharacterUnion]
        let characters: [String: [Interfaces.Character]]
        let droid: [String: Objects.Droid]
        let droids: [String: [Objects.Droid]]
        let greeting: [String: String]
        let human: [String: Objects.Human]
        let humans: [String: [Objects.Human]]
        let luke: [String: Objects.Human]
        let time: [String: DateTime]
        let whoami: [String: String]

        enum TypeName: String, Codable {
            case query = "Query"
        }
    }
}

extension Objects.Query: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var map = HashMap()
        for codingKey in container.allKeys {
            if codingKey.isTypenameKey { continue }

            let alias = codingKey.stringValue
            let field = GraphQLField.getFieldNameFromAlias(alias)

            switch field {
            case "whoami":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "luke":
                if let value = try container.decode(Objects.Human?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "human":
                if let value = try container.decode(Objects.Human?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "time":
                if let value = try container.decode(DateTime?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "droids":
                if let value = try container.decode([Objects.Droid]?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "droid":
                if let value = try container.decode(Objects.Droid?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "greeting":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "characters":
                if let value = try container.decode([Interfaces.Character]?.self, forKey: codingKey) {
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
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unknown key \(field)."
                    )
                )
            }
        }

        whoami = map["whoami"]
        luke = map["luke"]
        human = map["human"]
        time = map["time"]
        droids = map["droids"]
        droid = map["droid"]
        greeting = map["greeting"]
        characters = map["characters"]
        character = map["character"]
        humans = map["humans"]
    }
}

extension Fields where TypeLock == Objects.Query {
    func human<Type>(id: String, selection: Selection<Type, Objects.Human?>) throws -> Type {
        let field = GraphQLField.composite(
            name: "human",
            arguments: [Argument(name: "id", type: "ID!", value: id)],
            selection: selection.selection
        )
        select(field)

        switch response {
        case let .decoding(data):
            return try selection.decode(data: data.human[field.alias!])
        case .mocking:
            return selection.mock()
        }
    }

    func droid<Type>(id: String, selection: Selection<Type, Objects.Droid?>) throws -> Type {
        let field = GraphQLField.composite(
            name: "droid",
            arguments: [Argument(name: "id", type: "ID!", value: id)],
            selection: selection.selection
        )
        select(field)

        switch response {
        case let .decoding(data):
            return try selection.decode(data: data.droid[field.alias!])
        case .mocking:
            return selection.mock()
        }
    }

    func character<Type>(id: String, selection: Selection<Type, Unions.CharacterUnion?>) throws -> Type {
        let field = GraphQLField.composite(
            name: "character",
            arguments: [Argument(name: "id", type: "ID!", value: id)],
            selection: selection.selection
        )
        select(field)

        switch response {
        case let .decoding(data):
            return try selection.decode(data: data.character[field.alias!])
        case .mocking:
            return selection.mock()
        }
    }

    func luke<Type>(selection: Selection<Type, Objects.Human?>) throws -> Type {
        let field = GraphQLField.composite(
            name: "luke",
            arguments: [],
            selection: selection.selection
        )
        select(field)

        switch response {
        case let .decoding(data):
            return try selection.decode(data: data.luke[field.alias!])
        case .mocking:
            return selection.mock()
        }
    }

    func humans<Type>(selection: Selection<Type, [Objects.Human]>) throws -> Type {
        let field = GraphQLField.composite(
            name: "humans",
            arguments: [],
            selection: selection.selection
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.humans[field.alias!] {
                return try selection.decode(data: data)
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return selection.mock()
        }
    }

    func droids<Type>(selection: Selection<Type, [Objects.Droid]>) throws -> Type {
        let field = GraphQLField.composite(
            name: "droids",
            arguments: [],
            selection: selection.selection
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.droids[field.alias!] {
                return try selection.decode(data: data)
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return selection.mock()
        }
    }

    func characters<Type>(selection: Selection<Type, [Interfaces.Character]>) throws -> Type {
        let field = GraphQLField.composite(
            name: "characters",
            arguments: [],
            selection: selection.selection
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.characters[field.alias!] {
                return try selection.decode(data: data)
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return selection.mock()
        }
    }

    func greeting(input: OptionalArgument<InputObjects.Greeting> = .absent()) throws -> String {
        let field = GraphQLField.leaf(
            name: "greeting",
            arguments: [Argument(name: "input", type: "Greeting", value: input)]
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.greeting[field.alias!] {
                return data
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return String.mockValue
        }
    }

    func whoami() throws -> String {
        let field = GraphQLField.leaf(
            name: "whoami",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.whoami[field.alias!] {
                return data
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return String.mockValue
        }
    }

    func time() throws -> DateTime {
        let field = GraphQLField.leaf(
            name: "time",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.time[field.alias!] {
                return data
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return DateTime.mockValue
        }
    }
}

extension Selection where TypeLock == Never, Type == Never {
    typealias Query<T> = Selection<T, Objects.Query>
}

extension Objects {
    struct Subscription {
        let __typename: TypeName = .subscription
        let number: [String: Int]

        enum TypeName: String, Codable {
            case subscription = "Subscription"
        }
    }
}

extension Objects.Subscription: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var map = HashMap()
        for codingKey in container.allKeys {
            if codingKey.isTypenameKey { continue }

            let alias = codingKey.stringValue
            let field = GraphQLField.getFieldNameFromAlias(alias)

            switch field {
            case "number":
                if let value = try container.decode(Int?.self, forKey: codingKey) {
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

        number = map["number"]
    }
}

extension Fields where TypeLock == Objects.Subscription {
    /// Returns a random number every second. You should see it changing if your subscriptions work right.

    func number() throws -> Int {
        let field = GraphQLField.leaf(
            name: "number",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.number[field.alias!] {
                return data
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return Int.mockValue
        }
    }
}

extension Selection where TypeLock == Never, Type == Never {
    typealias Subscription<T> = Selection<T, Objects.Subscription>
}

// MARK: - Interfaces

enum Interfaces {}
extension Interfaces {
    struct Character {
        let __typename: TypeName
        let appearsIn: [String: [Enums.Episode]]
        let homePlanet: [String: String]
        let id: [String: String]
        let infoUrl: [String: String]
        let name: [String: String]
        let primaryFunction: [String: String]

        enum TypeName: String, Codable {
            case droid = "Droid"
            case human = "Human"
        }
    }
}

extension Interfaces.Character: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var map = HashMap()
        for codingKey in container.allKeys {
            if codingKey.isTypenameKey { continue }

            let alias = codingKey.stringValue
            let field = GraphQLField.getFieldNameFromAlias(alias)

            switch field {
            case "name":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "homePlanet":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "infoUrl":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "id":
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

        __typename = try container.decode(TypeName.self, forKey: DynamicCodingKeys(stringValue: "__typename")!)

        name = map["name"]
        homePlanet = map["homePlanet"]
        infoUrl = map["infoUrl"]
        id = map["id"]
        primaryFunction = map["primaryFunction"]
        appearsIn = map["appearsIn"]
    }
}

extension Fields where TypeLock == Interfaces.Character {
    /// The id of the character

    func id() throws -> String {
        let field = GraphQLField.leaf(
            name: "id",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.id[field.alias!] {
                return data
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return String.mockValue
        }
    }

    /// The name of the character

    func name() throws -> String {
        let field = GraphQLField.leaf(
            name: "name",
            arguments: []
        )
        select(field)

        switch response {
        case let .decoding(data):
            if let data = data.name[field.alias!] {
                return data
            }
            throw SG.HttpError.badpayload
        case .mocking:
            return String.mockValue
        }
    }
}

extension Fields where TypeLock == Interfaces.Character {
    func on<Type>(droid: Selection<Type, Objects.Droid>, human: Selection<Type, Objects.Human>) throws -> Type {
        select([GraphQLField.fragment(type: "Droid", selection: droid.selection), GraphQLField.fragment(type: "Human", selection: human.selection)])

        switch response {
        case let .decoding(data):
            switch data.__typename {
            case .droid:
                let data = Objects.Droid(appearsIn: data.appearsIn, id: data.id, name: data.name, primaryFunction: data.primaryFunction)
                return try droid.decode(data: data)
            case .human:
                let data = Objects.Human(appearsIn: data.appearsIn, homePlanet: data.homePlanet, id: data.id, infoUrl: data.infoUrl, name: data.name)
                return try human.decode(data: data)
            }
        case .mocking:
            return droid.mock()
        }
    }
}

extension Selection where TypeLock == Never, Type == Never {
    typealias Character<T> = Selection<T, Interfaces.Character>
}

// MARK: - Unions

enum Unions {}
extension Unions {
    struct CharacterUnion {
        let __typename: TypeName
        let appearsIn: [String: [Enums.Episode]]
        let homePlanet: [String: String]
        let id: [String: String]
        let infoUrl: [String: String]
        let name: [String: String]
        let primaryFunction: [String: String]

        enum TypeName: String, Codable {
            case human = "Human"
            case droid = "Droid"
        }
    }
}

extension Unions.CharacterUnion: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var map = HashMap()
        for codingKey in container.allKeys {
            if codingKey.isTypenameKey { continue }

            let alias = codingKey.stringValue
            let field = GraphQLField.getFieldNameFromAlias(alias)

            switch field {
            case "appearsIn":
                if let value = try container.decode([Enums.Episode]?.self, forKey: codingKey) {
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
            case "id":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "homePlanet":
                if let value = try container.decode(String?.self, forKey: codingKey) {
                    map.set(key: field, hash: alias, value: value as Any)
                }
            case "infoUrl":
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

        __typename = try container.decode(TypeName.self, forKey: DynamicCodingKeys(stringValue: "__typename")!)

        appearsIn = map["appearsIn"]
        name = map["name"]
        primaryFunction = map["primaryFunction"]
        id = map["id"]
        homePlanet = map["homePlanet"]
        infoUrl = map["infoUrl"]
    }
}

extension Fields where TypeLock == Unions.CharacterUnion {
    func on<Type>(human: Selection<Type, Objects.Human>, droid: Selection<Type, Objects.Droid>) throws -> Type {
        select([GraphQLField.fragment(type: "Human", selection: human.selection), GraphQLField.fragment(type: "Droid", selection: droid.selection)])

        switch response {
        case let .decoding(data):
            switch data.__typename {
            case .human:
                let data = Objects.Human(appearsIn: data.appearsIn, homePlanet: data.homePlanet, id: data.id, infoUrl: data.infoUrl, name: data.name)
                return try human.decode(data: data)
            case .droid:
                let data = Objects.Droid(appearsIn: data.appearsIn, id: data.id, name: data.name, primaryFunction: data.primaryFunction)
                return try droid.decode(data: data)
            }
        case .mocking:
            return human.mock()
        }
    }
}

extension Selection where TypeLock == Never, Type == Never {
    typealias CharacterUnion<T> = Selection<T, Unions.CharacterUnion>
}

// MARK: - Enums

enum Enums {}
extension Enums {
    /// One of the films in the Star Wars Trilogy
    enum Episode: String, CaseIterable, Codable {
        /// Released in 1977.

        case newhope = "NEWHOPE"
        /// Released in 1980.

        case empire = "EMPIRE"
        /// Released in 1983

        case jedi = "JEDI"
    }
}

extension Enums {
    /// Language
    enum Language: String, CaseIterable, Codable {
        case en = "EN"

        case sl = "SL"
    }
}

// MARK: - Input Objects

enum InputObjects {}
extension InputObjects {
    struct Greeting: Encodable, Hashable {
        var language: OptionalArgument<Enums.Language> = .absent()

        var name: String

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            if language.hasValue { try container.encode(language, forKey: .language) }
            try container.encode(name, forKey: .name)
        }

        enum CodingKeys: String, CodingKey {
            case language
            case name
        }
    }
}

extension InputObjects {
    struct GreetingOptions: Encodable, Hashable {
        var prefix: OptionalArgument<String> = .absent()

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            if prefix.hasValue { try container.encode(prefix, forKey: .prefix) }
        }

        enum CodingKeys: String, CodingKey {
            case prefix
        }
    }
}
