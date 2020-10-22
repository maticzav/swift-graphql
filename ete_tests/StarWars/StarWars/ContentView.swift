import SwiftUI
import SwiftGraphQL

/* Playground */

enum Objects {
    /**
     type Query {
       hero(episode: Episode!): Character!
       human(id: ID!): Human
       droid(id: ID!): Droid!
       humans: [Human]!
     }
     */
    struct Query: Decodable {
        let humans: [Human?]
    }
    
    
    /**
     type Human {
       id: String!
       name: String!
       homePlanet: String
     }
     */
    // Objects here can all conform to decodable since they are all composed of lists/optionals/named scalar types in the end.
    struct Human: Decodable {
        let id: String?
        let name: String?
        let homePlanet: Bool?
    }
}

typealias QueryObject = Objects.Query
typealias HumanObject = Objects.Human


extension SelectionSet where TypeLock == HumanObject {
    /// The id of the character
    func id() -> String {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "id",
            arguments: [
                
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.id!
        }
        return "Matic Zavadlal"
    }
    
    /// The id of the character
    func id() -> String {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "id",
            arguments: [
                
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.id!
        }
        return "Matic Zavadlal"
    }
    
    /// The id of the character
    func id() -> String {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "id",
            arguments: [
                
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.id!
        }
        return "Matic Zavadlal"
    }
}


extension SelectionSet where TypeLock == QueryObject {
    
}


//struct Rocket {
//    let id: String
//    let name: String
//    let company: String
//    let engines: Engine?
//}
//
//struct Engine {
//    let type: String
//    let layout: String?
//}
//
//let shipObject = Selection<Any, ShipObject> {
//    $0.class()
//}
//
//let engine = Selection<Engine, RocketenginesObject> {
//    Engine(type: $0.type()!, layout: $0.layout()!)
//}
//
//let rocket = Selection<Rocket, RocketObject> {
//    Rocket(
//        id: $0.id()!,
//        name: $0.name()!,
//        company: $0.company()!,
//        engines: $0.engines(engine.nullable)
//    )
//}
//
//let query = Selection<[Rocket]?, RootQuery> {
//    $0.rockets(rocket.nullable.list.nullable).map { $0.compactMap { $0 } }
//}

//struct Human {
//    let id: String
//    let name: String
//}
//
//let human = Selection<Human, HumanObject> {
//    Human(
//        id: $0.id(),
//        name: $0.name()
//    )
//}
//
//let query = Selection<Human?, RootQuery> {
//    $0.human(id: "1001", human.nullable)
//}








/* View */

class AppState: ObservableObject {
    let client = GraphQLClient(endpoint: URL(string: "http://localhost:4000")!)
    
    // MARK: - State
    
    @Published private(set) var humans: [Human] = []

    // MARK: - Intentions
    
    func fetch() {
        client.send(selection: query) { result in
            do {
                let data = try result.get()
                DispatchQueue.main.async {
                    self.humans = data.data.map { [$0!] } ?? []
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
//                        Text(human.homePlanet ?? "Unknown")
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
