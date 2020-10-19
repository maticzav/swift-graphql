import SwiftGraphQL

// MARK: - Operations

/* Query */

extension SelectionSet where TypeLock == RootQuery {
    /// human
    
    func human<Type>(_ selection: Selection<Type, HumanObject?>) -> Type {
        /* Selection */
        let field = GraphQLField.composite(name: "human", selection: selection.selection)
        self.select(field)

        /* Decoder */
        if let data = self.response {
            return selection.decode(data: ((data as! [String: Any])[field.name] as! Any?))
        }
        return selection.mock()
    }

    /// droid
    
    func droid<Type>(_ selection: Selection<Type, DroidObject?>) -> Type {
        /* Selection */
        let field = GraphQLField.composite(name: "droid", selection: selection.selection)
        self.select(field)

        /* Decoder */
        if let data = self.response {
            return selection.decode(data: ((data as! [String: Any])[field.name] as! Any?))
        }
        return selection.mock()
    }

    /// humans
    
    func humans<Type>(_ selection: Selection<Type, [HumanObject?]?>) -> Type {
        /* Selection */
        let field = GraphQLField.composite(name: "humans", selection: selection.selection)
        self.select(field)

        /* Decoder */
        if let data = self.response {
            return selection.decode(data: ((data as! [String: Any])[field.name] as! [Any?]?))
        }
        return selection.mock()
    }
}

// MARK: - Objects

enum Object {
    enum Droid {}
    enum Human {}
}

typealias DroidObject = Object.Droid
typealias HumanObject = Object.Human

// MARK: - Selection

/* Droid */

extension SelectionSet where TypeLock == DroidObject {
    /// The id of the character
    
    func id() -> String? {
        /* Selection */
        let field = GraphQLField.leaf(name: "id")
        self.select(field)

        /* Decoder */
        if let data = self.response {
            return (data as! [String: Any])[field.name] as! String?
        }
        return nil
    }

    /// The name of the character
    
    func name() -> String? {
        /* Selection */
        let field = GraphQLField.leaf(name: "name")
        self.select(field)

        /* Decoder */
        if let data = self.response {
            return (data as! [String: Any])[field.name] as! String?
        }
        return nil
    }

    /// Which movies they appear in.
    
    func appearsIn() -> [Episode?]? {
        /* Selection */
        let field = GraphQLField.leaf(name: "appearsIn")
        self.select(field)

        /* Decoder */
        if let data = self.response {
//            return ((data as! [String: Any])[field.name] as! [String?]?).map { Episode.init(rawValue: $0)! }
        }
        return []
    }

    /// The primary function of the droid.
    
    func primaryFunction() -> String? {
        /* Selection */
        let field = GraphQLField.leaf(name: "primaryFunction")
        self.select(field)

        /* Decoder */
        if let data = self.response {
            return (data as! [String: Any])[field.name] as! String?
        }
        return nil
    }
}


/* Human */

extension SelectionSet where TypeLock == HumanObject {
    /// The id of the character
    
    func id() -> String? {
        /* Selection */
        let field = GraphQLField.leaf(name: "id")
        self.select(field)

        /* Decoder */
        if let data = self.response {
            return (data as! [String: Any])[field.name] as! String?
        }
        return nil
    }

    /// The name of the character
    
    func name() -> String? {
        /* Selection */
        let field = GraphQLField.leaf(name: "name")
        self.select(field)

        /* Decoder */
        if let data = self.response {
            return (data as! [String: Any])[field.name] as! String?
        }
        return nil
    }

    /// Which movies they appear in.
    
    func appearsIn() -> [Episode?]? {
        /* Selection */
        let field = GraphQLField.leaf(name: "appearsIn")
        self.select(field)

        /* Decoder */
        if let data = self.response {
//            return ((data as! [String: Any])[field.name] as! [String?]?).map { Episode.init(rawValue: $0)! }
        }
        return []
    }

    /// The home planet of the human, or null if unknown.
    
    func homePlanet() -> String? {
        /* Selection */
        let field = GraphQLField.leaf(name: "homePlanet")
        self.select(field)

        /* Decoder */
        if let data = self.response {
            return (data as! [String: Any])[field.name] as! String?
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


/// MoreEpisodes
enum MoreEpisodes: String, CaseIterable, Codable {
    /// Released in 1977.
    
    case newhope = "NEWHOPE"

    /// Released in 1980.
    
    case empire = "EMPIRE"

    /// Released in 1983
    
    case jedi = "JEDI"

    /// OTHER
    
    case other = "OTHER"
}
