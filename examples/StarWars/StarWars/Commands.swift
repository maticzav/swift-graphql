import Foundation
import SwiftGraphQL

let characterId = Selection<String, Interfaces.Character> {
    try $0.id()
}

let character = Selection<Character, Interfaces.Character> {
    Character(
        id: try $0.selection(characterId),
        name: try $0.name(),
        message: try $0.on(
            droid: .init { try $0.primaryFunction() },
            human: .init { try $0.homePlanet() ?? "Unknown" }
        )
    )
}

let human = Selection<Human, Objects.Human> {
    Human(
        id: try $0.id(),
        name: try $0.name(),
        url: try $0.infoUrl()
    )
}

let foo: Selection<Human?, Objects.Human> = human.map { $0 }

let luke = Selection<String?, Interfaces.Character> { _ in
    nil
}

let nullableLuke: Selection<String?, Interfaces.Character?> = luke.optional()

let characterInterface = Selection<String, Interfaces.Character> {
    /* Common */
    let name = try $0.name()

    /* Fragments */
    let about = try $0.on(
        droid: Selection<String, Objects.Droid> { droid in try droid.primaryFunction() },
        human: Selection<String, Objects.Human> { human in try human.infoUrl() ?? "Unknown" }
    )

    return "\(name). \(about)"
}

let characterUnion = Selection<String, Unions.CharacterUnion> {
    try $0.on(
        human: .init { try $0.infoUrl() ?? "Unknown" },
        droid: .init { try $0.primaryFunction() }
    )
}

// MARK: - Query

let query = Selection<Data, Objects.Query> {
    let english = try $0.greeting()
    let slovene = try $0.greeting(input: .present(.init(name: "Matic")))

    let greeting = "\(english); \(slovene)"

    return Data(
        whoami: try $0.whoami(),
        time: try $0.time(),
        greeting: greeting,
        character: try $0.character(id: "1000", characterUnion.nonNullOrFail),
        characters: try $0.characters(Selection.list(character))
    )
}
