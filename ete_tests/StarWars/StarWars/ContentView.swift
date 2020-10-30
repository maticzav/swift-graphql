import SwiftUI
import SwiftGraphQL

/* Playground */


struct Character: Identifiable {
    let id: String
    let name: String
    let message: String
}

let character = Selection<Character, Interfaces.Character> {
    Character(
        id: $0.id(),
        name: $0.name(),
        message: $0.on(
            droid: .init { $0.primaryFunction() },
            human: .init { $0.homePlanet() ?? "Unknown" }
        )
    )
}

struct Human {
    let id: String
    let name: String
}

let human = Selection<Human, Objects.Human> {
    Human(id: $0.id(), name: $0.name())
}

let characterUnion = Selection<String, Unions.CharacterUnion> {
    $0.on(
        human: .init { $0.homePlanet() ?? "Unknown" },
        droid: .init { $0.primaryFunction() }
    )
}

struct Model {
    let time: DateTime?
    let greeting: String
    let character: String
    let characters: [Character]
}

let query = Selection<Model, Operations.Query> {
    let english = $0.greeting(input: .init(name: "Matic"))
    let slovene = $0.greeting(input: .init(language: .present(.en), name: "Matic"))
    
    let greeting = "\(english); \(slovene)"
    
    return Model(
        time: $0.time(),
        greeting: greeting,
        character: $0.character(id: "3000", characterUnion.nullable) ?? "No character",
        characters: $0.characters(character.list)
    )
}

/* View */

class AppState: ObservableObject {
    let client = GraphQLClient(endpoint: URL(string: "http://localhost:4000")!)
    
    // MARK: - State
    
    @Published private(set) var model = Model(
        time: nil,
        greeting: "Not greeted yet.",
        character: "NONE",
        characters: []
    )

    // MARK: - Intentions
    
    func fetch() {
        print("FETCHING")
        client.send(selection: query) { result in
            do {
                let data = try result.get()
                print("DATA")
                print(data)
                DispatchQueue.main.async {
                    if let data = data.data {
                        self.model = data
                    }
                }
            } catch let error {
                print("ERROR")
                print(error)
            }
        }
    }
    
}

struct ContentView: View {
    @ObservedObject private var state = AppState()
    
    var body: some View {
        NavigationView {
            VStack {
                /* Greeting */
                HStack {
                    Text(state.model.greeting)
                        .font(.headline)
                    Spacer()
                    Text(state.model.character)
                }
                .padding()
                /* Time */
                HStack {
                    Text(state.model.time?.value ?? "What's the time??")
                        .font(.headline)
                    Spacer()
                    Text("\(state.model.time?.raw ?? 0)")
                        .font(.headline)
                }
                .padding()
                /* Characters */
                List {
                    ForEach(state.model.characters, id: \.id) { character in
                        VStack {
                            Text(character.name)
                            Text(character.message)
                        }
                    }
                }
            }
            .navigationTitle("StarWars 🌌")
        }
        .onAppear(perform: {
            state.fetch()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
