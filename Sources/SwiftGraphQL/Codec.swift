import Foundation

// MARK: - Spec

/// Codec protocol describes the necessery requirements to make it compatible with SwiftGraphQL.
public protocol Codec: Codable & Hashable {
    associatedtype WrappedType

    /// Provides a default value used to mock in SwiftGraphQL selection set.
    ///
    /// - NOTE: This value is used by the generated functions, it can be of any value conforming to your type.
    static var mockValue: WrappedType { get }
}

// MARK: - Built-In Codecs

extension String: Codec {
    public static let mockValue = "Matic Zavadlal"
}

extension Int: Codec {
    public static let mockValue = 92
}

extension Bool: Codec {
    public static let mockValue = true
}

extension Double: Codec {
    public static let mockValue = 3.14
}
