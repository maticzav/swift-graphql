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
        droid: .init { $0.primaryFunction() },
        human: .init { $0.homePlanet() ?? "Unknown" }
    )
}

struct Model {
    let greeting: String
    let character: String
    let characters: [Character]
}

let query = Selection<Model, Operations.Query> {
    Model(
        greeting: $0.greeting(input: .init(language: .en, name: "Matic")),
        character: $0.character(id: "1001", characterUnion.nullable) ?? "No character",
        characters: $0.characters(character.list)
    )
}

/* View */

class AppState: ObservableObject {
    let client = GraphQLClient(endpoint: URL(string: "http://localhost:4000")!)
    
    // MARK: - State
    
    @Published private(set) var model = Model(
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
