import SwiftGraphQL

struct Date: Codec {
    typealias WrappedType = String
    
    static var mockValue: String = "FOO"
}

struct uuid: Codec {
    typealias WrappedType = String
    
    static var mockValue: String = "FOO"
}
