import ArgumentParser
import SwiftGraphQLCodegen
import Yams

struct SwiftGraphQLCLI: ParsableCommand {
    // MARK: - Parameters

    @Argument(help: "GraphQL server endpoint.")
    var endpoint: String

    @Option(help: "Relative path to your YML config file.")
    var config: String?

    @Option(name: .shortAndLong, help: "Relative path to the output file.")
    var output: String?

    // MARK: - Main

    mutating func run() throws {}
}

SwiftGraphQLCLI.main()
