import Foundation

/*
 SwiftAST is organised so that every possible component is
 */

// MARK: - Block

public indirect enum Block {
    /// Represents an import statement in a file.
    case `import`(Import)

    /// Represents an extension of a structure.
    case `extension`(String)

    /// Represents an enum block.
    case `enum`

    /// Represents a structure block.
    case `struct`

    /// Maps a collection of blocks into a single block.
    case blocks([Block])
    
//    "",
//    "// MARK: - Interfaces",
//    "",
//    "enum Interfaces {}",
    
    /// Creates a namespace enumerator.
    case namespace(String)
}

public protocol BlockProtocol {
    /// Returns a block representation of the type.
    var block: Block { get }
}

public struct Import {
    var module: String
}

public struct Enum: BlockProtocol {
    var name: String

    var docs: String?
    var protocols: [String]
    var cases: [Case]

    // MARK: - Initalizer

    public init(
        name: String,
        docs: String?,
        protocols: [String] = [],
        cases: [Case]
    ) {
        self.name = name
        self.docs = docs
        self.protocols = protocols
        self.cases = cases
    }

    public var block: Block {
        .enum
    }

    // MARK: - Case

    public struct Case {
        var name: String
        /// Represents the raw value of an enum case.
        var value: String
        var docs: String?
        var availability: String?

        // MARK: - Initializer

        public init(
            name: String,
            value: String,
            docs: String?,
            availability: String?
        ) {
            self.name = name
            self.value = value
            self.docs = docs
            self.availability = availability
        }

        // MARK: - Code

        var code: String {
            """
            """
        }
    }
}

public struct Extension {}

// MARK: - Printer

/// Returns a Swift code representing a block.
public func print<T>(block: T) -> String where T: BlockProtocol {
    return ""
}

enum Foo: Int {
    case one = 1; case two; case three
}
