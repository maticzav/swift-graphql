// This file is heavily inspired by https://github.com/relay-tools/Relay.swift.

import Foundation
import SwiftGraphQLClient
import SwiftUI
import os

/// Environment key used to identify the shared SwiftGraphQL client instance.
struct SGQLClientEnvironmentKey: EnvironmentKey {
    static var defaultValue: SwiftGraphQLClient.Client? { nil }
}

struct SGQLLoggerEnvironmentKey: EnvironmentKey {
    static var defaultValue: Logger? { nil }
}

extension EnvironmentValues {
    /// Environment value used to acces the shared SwiftGraphQL client instance.
    public var swiftGraphQLClient: SwiftGraphQLClient.Client? {
        get { self[SGQLClientEnvironmentKey.self] }
        set { self[SGQLClientEnvironmentKey.self] = newValue }
    }
    
    public var swiftGraphQLLogger: Logger? {
        get { self[SGQLLoggerEnvironmentKey.self] }
        set { self[SGQLLoggerEnvironmentKey.self] = newValue }
    }
}

public struct WithSwiftGraphQLEnvironment: ViewModifier {
    private let client: SwiftGraphQLClient.Client
    private let logger: Logger
    
    init(
        client: SwiftGraphQLClient.Client,
        logger: Logger = Logger(subsystem: "graphql", category: "client")
    ) {
        self.client = client
        self.logger = logger
    }
    
    public func body(content: Content) -> some View {
        content
            .environment(\.swiftGraphQLClient, client)
            .environment(\.swiftGraphQLLogger, logger)
    }
}

public extension View {
    /// Attaches a SwiftGraphQL environment to your view.
    func graphql(_ client: SwiftGraphQLClient.Client) -> some View {
        self.modifier(WithSwiftGraphQLEnvironment(client: client))
    }
}

/// Property wrapper that lets you access the shared SwiftGraphQL environment.
@propertyWrapper
public struct SwiftGraphQLEnvironment: DynamicProperty {
    @SwiftUI.Environment(\.swiftGraphQLClient) var client
    @SwiftUI.Environment(\.swiftGraphQLLogger) var logger
    
    public init() {}
    
    public var wrappedValue: Environment {
        Environment(client: client!, logger: logger!)
    }
    
    // MARK: - Environment
    
    public struct Environment {
        
        /// The shared client used by SwiftGraphQL loaders.
        public let client: SwiftGraphQLClient.Client
        
        /// A central logger for SwiftGraphQL cient events.
        public let logger: Logger
    }
}
