import SwiftUI
import SwiftGraphQL

/* Playground */

enum Objects {
    // Objects here can all conform to decodable since they are all composed of lists/optionals/named scalar types in the end.
}

/* Query */

extension Objects {
    /**
     type Query {
       hero(episode: Episode!): Character!
       human(id: ID!): Human
       droid(id: ID!): Droid!
       humans: [Human]!
     }
     */
    struct Query: Codable {
        let humans: [Human?]?
    }
}

typealias QueryObject = Objects.Query

extension SelectionSet where TypeLock == QueryObject {
    func humans<Type>(_ selection: Selection<Type, [HumanObject?]>) -> Type {
        /* Selection */
        let field = GraphQLField.composite(
            name: "humans",
            arguments: [

            ],
            selection: selection.selection
        )
        self.select(field)

        /* Decoder */
        if let data = self.response {
            return selection.decode(data: data.humans!)
        }
        return selection.mock()
    }
}

/* Human */

extension Objects {
    /**
     type Human {
       id: String!
       name: String!
       homePlanet: String
     }
     */

    struct Human: Codable {
        let id: String?
        let name: String?
        let homePlanet: String?
        let appearsIn: [Episode]?
    }
}

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
    func name() -> String {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "name",
            arguments: [
                
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.name!
        }
        return "Matic Zavadlal"
    }
    
    /// The id of the character
    func homePlanet() -> String? {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "homePlanet",
            arguments: [
                
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.homePlanet
        }
        return "Matic Zavadlal"
    }
    
    /// The id of the character
    func appearsIn() -> [Episode] {
        /* Selection */
        let field = GraphQLField.leaf(
            name: "appearsIn",
            arguments: [
                
            ]
        )
        self.select(field)
    
        /* Decoder */
        if let data = self.response {
            return data.appearsIn!
        }
        return []
    }
}

/// One of the films in the Star Wars Trilogy
enum Episode: String, CaseIterable, Codable {
    /// Released in 1977.
    case newhope = "NEWHOPE"

    /// Released in 1980.
    case empire = "EMPIRE"

    /// Released in 1983
    case jedi = "JEDI"
}


/* Playground */


struct Human {
    let id: String
    let name: String
    let homePlanet: String
    let appearsIn: String
}

let human = Selection<Human, HumanObject> {
    Human(
        id: $0.id(),
        name: $0.name(),
        homePlanet: $0.homePlanet() ?? "Unknown",
        appearsIn: $0.appearsIn().map { $0.rawValue }.joined(separator: "\n")
    )
}

let query = Selection<[Human?], QueryObject> {
    $0.humans(human.nullable.list)
}


let luke = Objects.Human(
    id: "21",
    name: "Luke",
    homePlanet: nil,
    appearsIn: []
)

let encoder = JSONEncoder()
let json = try? encoder.encode(luke)



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
                        Text(human.appearsIn)
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
