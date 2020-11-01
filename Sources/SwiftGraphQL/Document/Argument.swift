import Foundation

/**
 Argument represents a single variable in the GraphQL query.
 
 We use it internally in the generated code to pass down information
 about the field and the type of the field it encodes as well as the value itself.
 */
public struct Argument: Hashable {
    let name: String
    let type: String
    let hash: String
    let value: NSObject?
    
    /*
     NOTE:
        We use an internal VariableEncoder structure that is
        a chiseled version of Swift's JSONEncoder. The main difference
        is that we leave the result in a NSObject format while
        JSONEncoder serializes it. This way we can pass the NSObject parameter to
        the execution function where we use the value inside the variables
        dictionary.

        The main benefit of this approach is that we don't need to express
        serializable types using generics, which would be impossible to do
        considering the structure of the project.
     
        We serialize arguments in two ways:
            1. Firstly, we include it in the parameter list of a single field,
            2. Secondly, we include it in the variables parameter that lets us
               pass input parameters to our queries.
     
        I considered writing a custom serializer for the input format that GraphQL uses,
        but it would turn out less performant and I'd have to introduce nieche hacks to
        represent enumerators as non-string values.
     */
    
    // MARK: - Initializer
    
    /// Returns a new argument with the given value.
    public init<T: Encodable & Hashable>(name: String, type: String, value: T) {
        self.name = name
        self.type = type
        self.hash = hashInt(value.hashValue)
        
        /* Encode value */
        if let value = value as? OptionalArgumentProtocol, !value.hasValue {
            self.value = nil
        } else {
            self.value = try! VariableEncoder().encode(value)
        }
    }
}

// MARK: - Hashing

extension Array where Element == Argument {
    /// Returns the hash of the collection of arguments.
    var hash: String { hashInt(self.hashValue) }
}

/**
 Returns the condensed representation of a string that only contains alpha-numeric characters.
 
 - Note: We convert the integer hash value to a higher number system to shorten the hash, and replace the sign (i.e. negation)
         with an underscore so that it conforms to alpha-numeric restriction.
 */
private func hashInt(_ value: Int) -> String {
    let hash = String(value, radix: 36)
    let normalized = hash.replacingOccurrences(of: "-", with: "_")
    return "_\(normalized)"
}
