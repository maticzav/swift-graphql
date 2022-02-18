import Foundation

/// An identifier associated with comic struct.
public struct ComicId: Hashable {
    private var id: String
    
    public init(string id: String) {
        self.id = id
    }
    
    /// Returns a string representation of the identifier.
    public var string: String {
        self.id
    }
}

public struct Comic: Identifiable {
    public var id: ComicId

    public var title: String
    public var description: String
    public var thumbnail: URL

    /// Characters that appear in this comic.
    public var characters: [Character]

    public var isbn: String?
    public var pageCount: Int

    /// Tells whether the currently authenticated user has starred the comic.
    public var starred: Bool

    // MARK: - Initializer

    public init(
        id: ComicId,
        title: String,
        description: String,
        thumbnail: URL,
        characters: [Character],
        isbn: String? = nil,
        pageCount: Int,
        starred: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description

        self.thumbnail = thumbnail
        self.characters = characters

        self.isbn = isbn
        self.pageCount = pageCount

        self.starred = starred
    }
    
    // MARK: - Previews
    
    public static let avangers = Comic(
        id: ComicId(string: "mck-avangers"),
        title: "Avangers",
        description: "The Runaways are here! Giant-Man and Victor, Reptil and Chase, Lightspeed and Karolina. What happens when these two super-charged teams collide?",
        thumbnail: URL(string: "https://i.annihil.us/u/prod/marvel/i/mg/3/e0/51685ee793f01/portrait_fantastic.jpg")!,
        characters: [],
        pageCount: 32
    )
    
    public static let captainamerica = Comic(
        id: ComicId(string: "mck-cptnam"),
        title: "Captain America",
        description: "Is this the next Sentinel of Liberty? Introducing Free Spirit!",
        thumbnail: URL(string: "https://i.annihil.us/u/prod/marvel/i/mg/4/40/4d948156dc991/portrait_fantastic.jpg")!,
        characters: [],
        pageCount: 36
    )
    
    public static let deadpool = Comic(
        id: ComicId(string: "mck-deadpool"),
        title: "Deadpool",
        description: "When Black Tom's men break into Deadpool's favorite bar to kidnap the Merc, Siryn and Banshee show up to help Deadpool out. But with Deadpool's healing factor on the fritz, can he survive?",
        thumbnail: URL(string: "https://i.annihil.us/u/prod/marvel/i/mg/e/b0/4bb6224caeea5/portrait_fantastic.jpg")!,
        characters: [],
        pageCount: 36
    )
    
    public static let starwars = Comic(
        id: ComicId(string: "mck-starwars"),
        title: "Star Wars",
        description: "The Hero of the Rebellion & the Princess of the Revolution! Luke and Leia finally get some time alone. Unfortunately, it's stranded on a desert island.",
        thumbnail: URL(string: "https://i.annihil.us/u/prod/marvel/i/mg/9/20/59553b0f25aea/portrait_fantastic.jpg")!,
        characters: [],
        pageCount: 32
    )
}
