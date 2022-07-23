import ArgumentParser
import Files
import Foundation
import GraphQLAST
import Spinner
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
    
    @Option(
        name: .shortAndLong,
        help: "Custom headers to include in the request in format \"Header: Value\""
    )
    var header: [String] = []
    
    // MARK: - Configuration
    
    static var configuration = CommandConfiguration(
        commandName: "swift-graphql"
    )

    // MARK: - Main

    func run() throws {
        print("Generating SwiftGraphQL Selection 🚀")
        
        // Make sure we get a valid endpoint file or URL endpoint.
        guard var url = URL(string: endpoint) else {
            SwiftGraphQLCLI.exit(withError: .endpoint)
        }
        
        // Covnert relative URLs to absolute ones.
        if url.scheme == nil {
            guard #available(macOS 12, *) else {
                SwiftGraphQLCLI.exit(withError: .legacy)
            }
            
            var cwd = FilePath(FileManager.default.currentDirectoryPath)
            if endpoint.starts(with: "/") {
                cwd = FilePath("/")
            }
            
            guard let fileurl = URL(cwd.appending(endpoint)) else {
                SwiftGraphQLCLI.exit(withError: .endpoint)
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
        
        if !self.header.isEmpty {
            print("Adding headers to your request:")
        }
        
        // Add headers to the request.
        var headers: [String: String] = [:]
        for header in self.header {
            // Each header is split into two parts on the `: `
            // separator as in cURL spec.
            let parts = header.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            guard parts.count == 2 else {
                SwiftGraphQLCLI.exit(withError: .header)
            }
            
            let name = String(parts[0])
            let value = parts[1].trimmingCharacters(in: CharacterSet.whitespaces)
            headers[name] = value
            
            print(" - \(name): \(value)")
        }
        
        // Fetch the schema.
        let loadSchemaSpinner = Spinner(.dots, "Fetching GraphQL Schema")
        loadSchemaSpinner.start()
        let schema = try Schema(from: url, withHeaders: headers)
        loadSchemaSpinner.stop()

        // Generate the code.
        let generateCodeSpinner = Spinner(.dots, "Generating API")
        generateCodeSpinner.start()
        
        let generator = GraphQLCodegen(scalars: config.scalars)
        let code: String
        
        do {
            code = try generator.generate(schema: schema)
            generateCodeSpinner.stop()
        } catch CodegenError.formatting(let err) {
            print(err.localizedDescription)
            SwiftGraphQLCLI.exit(withError: .formatting)
        } catch IntrospectionError.emptyfile, IntrospectionError.unknown {
            SwiftGraphQLCLI.exit(withError: .introspection)
        } catch IntrospectionError.statusCode(let code) {
            print("Received status code \(code) while introspecting the schema...")
            SwiftGraphQLCLI.exit(withError: .introspection)
        } catch IntrospectionError.error(let err) {
            print(err.localizedDescription)
            SwiftGraphQLCLI.exit(withError: .introspection)
        } catch {
            SwiftGraphQLCLI.exit(withError: .unknown)
        }

        // Write to target file or stdout.
        if let outputPath = output {
            try Folder.current.createFile(at: outputPath).write(code)
        } else {
            FileHandle.standardOutput.write(code.data(using: .utf8)!)
        }
        
        print("\n\nAPI generated successfully!")
        
        // Warn about the unused scalars.
        let ignoredScalars = try schema.missing(scalars: config.scalars)
        guard !ignoredScalars.isEmpty else {
            return
        }
        
        let message = """
        Your schema contains some unknown scalars:
        
        \(ignoredScalars.map { " - \($0)" }.joined(separator: "\n"))
        
        Add them to the config to get better type support!
        """
        
        print(message)
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
    case introspection = "Couldn't introspect the schema."
    case header = "Invalid header format. Use `Header: Value` to specify a single header."
}

extension String: Error {}

extension ParsableCommand {
    /// Exits the program with an internal error.
    static func exit(withError error: SwiftGraphQLGeneratorError? = nil) -> Never {
        Self.exit(withError: error?.rawValue)
    }
}
