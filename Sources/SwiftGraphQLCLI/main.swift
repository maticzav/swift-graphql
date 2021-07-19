import ArgumentParser
import Files
import Foundation
import SwiftGraphQLCodegen
import Yams

SwiftGraphQLCLI.main()

// MARK: - CLI

struct SwiftGraphQLCLI: ParsableCommand {
    // MARK: - Parameters

    @Argument(help: "GraphQL server endpoint.")
    var endpoint: String

    @Option(help: "Relative path from CWD to your YML config file.")
    var config: String?

    @Option(name: .shortAndLong, help: "Relative path from CWD to the output file.")
    var output: String?
    
    @Option(help: "Include this Authorization header in the request to the endpoint.")
    var authorization: String?
    
    // MARK: - Configuration
    
    static var configuration = CommandConfiguration(
        commandName: "swift-graphql"
    )

    // MARK: - Main

    func run() throws {
        // Make sure we get a valid endpoint to fetch.
        guard let url = URL(string: endpoint) else {
            SwiftGraphQLCLI.exit(withError: SwiftGraphQLGeneratorError.endpoint)
        }

        // Load configuration if config path is present, otherwise use default.
        let config: Config

        if let configPath = self.config {
            let raw = try Folder.current.file(at: configPath).read()
            config = try Config(from: raw)
        } else {
            config = Config()
        }
        
        var headers: [String: String] = [:]
        
        if let authorization = authorization {
            headers["Authorization"] = authorization
        }

        // Generate the code.
        let generator = GraphQLCodegen(scalars: config.scalars)
        let code = try generator.generate(from: url, withHeaders: headers)

        // Write to target file or stdout.
        if let outputPath = output {
            try Folder.current.file(at: outputPath).write(code)
        } else {
            FileHandle.standardOutput.write(code.data(using: .utf8)!)
        }

        // The end
    }
}

// MARK: - Configuraiton

/*
 swiftgraphql.yml

 ```yml
 scalars:
     Date: DateTime
 ```
 */

struct Config: Codable, Equatable {
    /// Key-Value dictionary of scalar mappings.
    let scalars: ScalarMap

    // MARK: - Initializers

    /// Creates an empty configuration instance.
    init() {
        scalars = ScalarMap()
    }

    /// Creates a new config instance from given parameters.
    init(scalars: ScalarMap) {
        self.scalars = scalars
    }

    /// Tries to decode the configuration from a string.
    init(from data: Data) throws {
        let decoder = YAMLDecoder()
        self = try decoder.decode(Config.self, from: data)
    }
}

// MARK: - Errors

enum SwiftGraphQLGeneratorError: String, Error {
    case endpoint = "Invalid endpoint!"
}
