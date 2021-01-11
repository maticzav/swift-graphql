import Foundation
import SwiftGraphQL

class Model: ObservableObject {
    // MARK: - State
    
    @Published private(set) var data = Data()

    // MARK: - Intentions
    
    func fetch() {
        print("FETCHING")
        
        // Perform query.
        SG.send(
            query,
            to: "http://localhost:4000",
            operationName: "Query",
            headers: ["Authorization": "Bearer Matic"]
        ) { result in
            do {
                let data = try result.get()
                print("DATA")
                print(data)
                DispatchQueue.main.async {
                    self.data = data.data
                }
            } catch let error {
                print(error)
            }
        }
    }
}

// MARK: - Submodels

struct Data {
    var whoami: String = "Who knows!?"
    var time: DateTime? = nil
    var greeting: String = "Not greeted yet."
    var character: String = "NONE"
    var characters: [Character] = []
}

struct Character: Identifiable {
    let id: String
    let name: String
    let message: String
//    let friend: [Character]
}

struct Human {
    let id: String
    let name: String
    let url: String?
}
