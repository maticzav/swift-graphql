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
        id: $0.id(),
        name: $0.name(),
        homePlanet: "Unknown"
    )
}

//let query = Selection<[Human?], RootQuery> {
//    $0.humans(human.nullable.list.nullable) ?? []
//}

struct Model {
    let greeting: String
}

let query = Selection<Model, RootQuery> {
    Model(greeting: $0.greeting(
            input: InputObjects.Greeting(language: nil, name: "Matic"))
    )
}

/* View */

class AppState: ObservableObject {
    let client = GraphQLClient(endpoint: URL(string: "http://localhost:4000")!)
    
    // MARK: - State
    
    @Published private(set) var model = Model(greeting: "Not greeted yet.")

    // MARK: - Intentions
    
    func fetch() {
        client.perform(operation: .query, selection: query) { result in
            do {
                let data = try result.get()
                DispatchQueue.main.async {
                    if let data = data.data {
                        self.model = data
                    }
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
//            List {
//                ForEach(state.humans, id: \.id) { human in
//                    VStack {
//                        Text(human.name)
//                        Text(human.homePlanet)
////                        Text(human.appearsIn)
//                    }
//                }
//            }
            Group {
                Text(state.model.greeting)
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
