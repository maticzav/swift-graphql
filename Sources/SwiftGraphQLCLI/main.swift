import ArgumentParser
import Files
import Foundation
import SwiftGraphQLCodegen
import System
import Yams

SwiftGraphQLCLI.main()

// MARK: - CLI

struct SwiftGraphQLCLI: ParsableCommand {
    // MARK: - Parameters

    @Argument(help: "GraphQL server endpoint or local file path from the current location.")
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
        
        // Make sure we get a valid endpoint file or URL endpoint.
        guard var url = URL(string: endpoint) else {
            SwiftGraphQLCLI.exit(withError: SwiftGraphQLGeneratorError.endpoint)
        }
        
        // Covnert relative URLs to absolute ones.
        if url.scheme == nil {
            guard #available(macOS 12, *) else {
                SwiftGraphQLCLI.exit(withError: SwiftGraphQLGeneratorError.legacy)
            }
            
            var cwd = FilePath(FileManager.default.currentDirectoryPath)
            if endpoint.starts(with: "/") {
                cwd = FilePath("/")
            }
            
            guard let fileurl = URL(cwd.appending(endpoint)) else {
                SwiftGraphQLCLI.exit(withError: SwiftGraphQLGeneratorError.endpoint)
            }
            url = fileurl
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
        let result: GraphQLCodegen.Output
        
        do {
            result = try generator.generate(from: url, withHeaders: headers)
        } catch CodegenError.formatting(let err) {
            print(err.localizedDescription)
            SwiftGraphQLCLI.exit(withError: SwiftGraphQLGeneratorError.formatting)
        } catch {
            SwiftGraphQLCLI.exit(withError: SwiftGraphQLGeneratorError.unknown)
        }

        // Write to target file or stdout.
        if let outputPath = output {
            try Folder.current.createFile(at: outputPath).write(result.code)
        } else {
            FileHandle.standardOutput.write(result.code.data(using: .utf8)!)
        }
        
        if !result.ignoredScalars.isEmpty {
            let message = """
            Some fields may be missing because they rely on unsupported types:
            \(result.ignoredScalars.map { " - \($0)" }.joined(separator: "\n"))
            """
            
            print(message)
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
    case legacy = "Please update your MacOS to use schema from a file."
    case formatting = "There was an error formatting the code. Make sure your Swift version (i.e. `swift-format`) matches the `swift-format` version. If you need any help, don't hesitate to open an issue and include the log above!"
    case unknown = "Something unexpected happened. Please open an issue and we'll help you out!"
}
