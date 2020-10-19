import SwiftUI
import SwiftGraphQL

/* Query */

struct Human: Identifiable {
    let id: String
    let name: String
}

let human = Selection<Human, HumanObject> {
    Human(id: $0.id(), name: $0.name())
}

let query = Selection<[Human], RootQuery> {
    $0.humans(human.nullable.list).compactMap { $0 }
}

/* View */

class AppState: ObservableObject {
    let client = GraphQLClient(endpoint: URL(string: "http://localhost:4000")!)
    
    // MARK: - State
    
    @Published private(set) var humans: [Human] = []

    // MARK: - Intentions
    
    func fetch() {
        client.send(selection: query) { result in
            print(result)
            switch result {
            case .success(let res):
                self.humans = res.data ?? []
            case .failure(_):
                ()
            }
        }
    }
    
}

struct ContentView: View {
    @ObservedObject private var state = AppState()
    
    var body: some View {
        List {
            ForEach(state.humans, id: \.id) { human in
                Text(human.name)
            }
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
