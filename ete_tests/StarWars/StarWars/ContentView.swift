import SwiftUI
import SwiftGraphQL

/* Playground */


struct Character: Identifiable {
    let id: String
    let name: String
    let message: String
}

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

struct Human {
    let id: String
    let name: String
    let url: String?
}

let human = Selection<Human, Objects.Human> {
    Human(
        id: try $0.id(),
        name: try $0.name(),
        url: try $0.infoUrl()
    )
}

let foo: Selection<Human?, Objects.Human> = human.map { $0 }

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

struct Model {
    let whoami: String
    let time: DateTime?
    let greeting: String
    let character: String
    let characters: [Character]
}

let query = Selection<Model, Operations.Query> {
    let english = try $0.greeting()
    let slovene = try $0.greeting(input: .present(.init(name: "Matic")))
    
    let greeting = "\(english); \(slovene)"
    
    return Model(
        whoami: try $0.whoami(),
        time: try $0.time(),
        greeting: greeting,
        character: try $0.character(id: "1000", characterUnion.nonNullOrFail),
        characters: try $0.characters(Selection.list(character))
    )
}

/* View */

class AppState: ObservableObject {
    // MARK: - State
    
    @Published private(set) var model = Model(
        whoami: "Who knows!?",
        time: nil,
        greeting: "Not greeted yet.",
        character: "NONE",
        characters: []
    )

    // MARK: - Intentions
    
    func fetch() {
        print("FETCHING")
        SG.send(
            query,
            to: "http://localhost:4000",
            headers: ["Authorization": "Bearer Matic"]
        ) { result in
            do {
                let data = try result.get()
                print("DATA")
                print(data)
                DispatchQueue.main.async {
                    self.model = data.data
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
                /* Authorization */
                HStack {
                    Text(state.model.whoami)
                        .font(.headline)
                    Spacer()
                }
                .padding()
                /* Characters */
                HStack {
                    Text("Characters")
                        .font(Font.title)
                    Spacer()
                }
                .padding()
                List {
                    ForEach(state.model.characters, id: \.id) { character in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(character.name)
                            Text(character.message)
                        }
                    }
                }
                .listStyle(PlainListStyle())
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
