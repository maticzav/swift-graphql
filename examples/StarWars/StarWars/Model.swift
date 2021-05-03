import Foundation
import SwiftGraphQL

class Model: ObservableObject {
    // MARK: - State

    @Published private(set) var data = Data()
    @Published private(set) var subscriptionData: Int = 0
    private var socket: GraphQLSocket<URLSessionWebSocketTask>?
    var cancellable: SocketCancellable?
    
    // MARK: - Intentions

    func fetch() {
        print("FETCHING")

        // Perform query.
        send(
            query,
            to: "http://localhost:4000/graphql",
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
            } catch {
                print("FETCH", error)
            }
        }
    }

    func startListening() {
        print("STARTED LISTENING")
        if socket == nil {
            socket = .init(URLSessionWebSocketTask.InitParamaters(url: URL(string: "ws://localhost:4000/subscriptions")!, headers: [:]), autoConnect: true)
        }
        
        cancellable = socket?.subscribe(to: subscription.nonNullOrFail) { [weak self] result in
            do {
                let resultValue = try result.get()
                print(resultValue)
                DispatchQueue.main.async {
                    self?.subscriptionData = resultValue.data
                }
            } catch {
                print("SUBS", error)
            }
        }
    }
    
    func stopListening() {
        cancellable = nil
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
