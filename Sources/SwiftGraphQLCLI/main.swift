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
        let schema: Schema
        do {
            schema = try Schema(from: url, withHeaders: headers)
        } catch(let err) {
            print(err.localizedDescription)
            SwiftGraphQLCLI.exit(withError: .unreachable)
        }
        
        loadSchemaSpinner.success("Schema loaded!")

        // Generate the code.
        let generateCodeSpinner = Spinner(.dots, "Generating API")
        generateCodeSpinner.start()
        
        let scalars = ScalarMap(scalars: config.scalars)
        let generator = GraphQLCodegen(scalars: scalars)
        let files: [GeneratedFile]

        do {
            files = try generator.generate(schema: schema)
            generateCodeSpinner.success("API generated successfully!")
        } catch CodegenError.formatting(let err) {
            generateCodeSpinner.error(err.localizedDescription)
            SwiftGraphQLCLI.exit(withError: .formatting)
        } catch IntrospectionError.emptyfile, IntrospectionError.unknown {
            SwiftGraphQLCLI.exit(withError: .introspection)
        } catch IntrospectionError.error(let err) {
            generateCodeSpinner.error(err.localizedDescription)
            SwiftGraphQLCLI.exit(withError: .introspection)
        } catch {
            SwiftGraphQLCLI.exit(withError: .unknown)
        }

        // Write to target file or stdout.
        if let outputPath = output {
            try? Folder.current.subfolder(at: outputPath).delete()
            for file in files {
                try Folder.current.createFile(at: "\(outputPath)/\(file.name).swift").write(file.contents)
            }
        } else {
            for file in files {
                let contents = "\n\n\(file.name).swift:\n" + file.contents
                FileHandle.standardOutput.write(contents.data(using: .utf8)!)
            }
        }
        
        let analyzeSchemaSpinner = Spinner(.dots, "Analyzing Schema")
        analyzeSchemaSpinner.start()
        
        // Warn about the unused scalars.
        let ignoredScalars = try schema.missing(from: scalars)
        guard !ignoredScalars.isEmpty else {
            analyzeSchemaSpinner.success("SwiftGraphQL Ready!")
            return
        }
        
        analyzeSchemaSpinner.stop()
        
        let message = """
        Your schema contains some unknown scalars:
        
        \(ignoredScalars.map { " - \($0)" }.joined(separator: "\n"))
        
        Add them to the config to get better type support!
        """
        print(message)
    }
}

// MARK: - Configuraiton


/**
 Configuration file specification for `swiftgraphql.yml`.

 ```yml
 scalars:
     Date: DateTime
 ```
 */
struct Config: Codable, Equatable {
    /// Key-Value dictionary of scalar mappings.
    let scalars: [String: String]

    // MARK: - Initializers

    /// Creates an empty configuration instance.
    init() {
        self.scalars = [:]
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
    case unreachable = "Couldn't reach GraphQL server at given endpoint."
}

extension String: Error {}

extension ParsableCommand {
    /// Exits the program with an internal error.
    static func exit(withError error: SwiftGraphQLGeneratorError? = nil) -> Never {
        Self.exit(withError: error?.rawValue)
    }
}
