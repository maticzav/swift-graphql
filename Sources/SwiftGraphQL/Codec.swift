import Foundation

// MARK: - Spec

/// Codec protocol describes the necessery requirements to make it compatible with SwiftGraphQL.
///
///
protocol Codec: Codable {
    associatedtype WrappedType
    
    /// Provides a default value used to mock in SwiftGraphQL selection set.
    ///
    /// - NOTE: This value is used by the generated functions, it can be of any value conforming to your type.
    static var mockValue: WrappedType { get }
}

// MARK: - Built-In Codecs

extension String: Codec {
    static let mockValue = "Matic Zavadlal"
}

extension Int: Codec {
    static let mockValue = 42
}

extension Bool: Codec {
    static let mockValue = true
}

extension Double: Codec {
    static let mockValue = 3.14
}
