import Foundation

/// An identifier associated with a character.
public struct CharacterId: Hashable {
	private var id: String

	public init(string id: String) {
		self.id = id
	}

	/// String representation of the identifier.
	public var string: String {
		self.id
	}
}
public struct Character: Identifiable, Hashable {
	public var id: CharacterId

	public var name: String
	public var description: String
	public var image: URL
    
    /// Comics this character has appeared in.
    public var comics: [Comic]

	/// Tells whether the currently authenticated user has starred the character.
	public var starred: Bool

	// MARK: - Initializer

	public init(
		id: CharacterId,
		name: String,
		description: String,
		image: URL,
		comics: [Comic],
		starred: Bool = false
	) {
		self.id = id

		self.name = name
		self.description = description
		self.image = image

		self.comics = comics

		self.starred = starred
	}

	// MARK: - Previews

	public static let ironman = Character(
		id: CharacterId(string: "mck-ironman"), 
		name: "Iron Man", 
		description: "Wounded, captured and forced to build a weapon by his enemies, billionaire industrialist Tony Stark instead created an advanced suit of armor to save his life and escape captivity. Now with a new outlook on life, Tony uses his money and intelligence to make the world a safer, better place as Iron Man.", 
		image: URL(string: "https://i.annihil.us/u/prod/marvel/i/mg/9/c0/527bb7b37ff55/standard_fantastic.jpg")!,
		comics: []
	)

	public static let wolverine = Character(
		id: CharacterId(string: "mck-wolverine"), 
		name: "Wolverine", 
		description: "Born with super-human senses and the power to heal from almost any wound, Wolverine was captured by a secret Canadian organization and given an unbreakable skeleton and claws. Treated like an animal, it took years for him to control himself. Now, he's a premiere member of both the X-Men and the Avengers.", 
		image: URL(string: "https://i.annihil.us/u/prod/marvel/i/mg/2/60/537bcaef0f6cf/standard_fantastic.jpg")!,
		comics: []
	)

	public static let spiderman = Character(
		id: CharacterId(string: "mck-spiderman"),
		name: "Spider Man",
		description: "Bitten by a radioactive spider, high school student Peter Parker gained the speed, strength and powers of a spider. Adopting the name Spider-Man, Peter hoped to start a career using his new abilities. Taught that with great power comes great responsibility, Spidey has vowed to use his powers to help people.",
		image: URL(string: "https://i.annihil.us/u/prod/marvel/i/mg/3/50/526548a343e4b/standard_fantastic.jpg")!,
		comics: []
	)
}
