import Foundation
import Files
import SwiftGraphQLCodegen


let endpoint = URL(string: "http://localhost:4000")!
let target = try! Folder.current.parent!
    .subfolder(at: "StarWars")
    .createFile(at: "API.swift").url

GraphQLCodegen.generate(target, from: endpoint) {
    print("Generate API to \(target)")
}
