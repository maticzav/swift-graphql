import SwiftUI
import SwiftGraphQL

/* Playground */


struct Human {
    let id: String
    let name: String
    let homePlanet: String
}

let human = Selection<Human, HumanObject> {
    Human(
        id: $0.id() ?? "ID",
        name: $0.name() ?? "Anonymous",
        homePlanet: "Unknown"
    )
}

//let query = Selection<[Human?], RootQuery> {
//    $0.humans(human.nullable.list.nullable) ?? []
//}

let query = Selection<[Human], RootQuery> {
    $0.human(id: "1001", human.nullable).map { [$0] } ?? []
}

/* View */

class AppState: ObservableObject {
    let client = GraphQLClient(endpoint: URL(string: "http://localhost:4000")!)
    
    // MARK: - State
    
    @Published private(set) var humans: [Human] = []

    // MARK: - Intentions
    
    func fetch() {
        client.perform(operation: .query, selection: query) { result in
            do {
                let data = try result.get()
                DispatchQueue.main.async {
                    self.humans = data.data!.compactMap { $0 }
                }
            } catch let error {
                print(error)
            }
        }
    }
    
}

struct ContentView: View {
    @ObservedObject private var state = AppState()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(state.humans, id: \.id) { human in
                    VStack {
                        Text(human.name)
                        Text(human.homePlanet)
//                        Text(human.appearsIn)
                    }
                }
            }
            .onAppear(perform: {
                state.fetch()
            })
            .navigationTitle("StarWars 🌌")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
