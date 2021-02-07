import Files
import Foundation
import SwiftGraphQLCodegen

// let endpoint = URL(string: "http://api.spacex.land/graphql")!
let endpoint = URL(string: "http://localhost:4000")!
// let endpoint = URL(string: "https://api.react-finland.fi/graphql")!

do {
    let target = try File(path: #file)
        .parent! // Codegen
        .parent! // Sources
        .parent! // Codegen
        .parent! // StarWars
        .subfolder(at: "StarWars")
        .createFile(at: "API.swift").url

    /* Create Generator */
    let generator = GraphQLCodegen(scalars: ["Date": "DateTime"])

    try generator.generate(target, from: endpoint)

    print("Generated API to \(target.absoluteString)")
} catch {
    print("ERROR: \(error.localizedDescription)")
    exit(1)
}
