import Foundation
import GraphQL

/**
 Argument represents a single variable in the GraphQL query.

 We use it internally in the generated code to pass down information
 about the field and the type of the field it encodes as well as the value itself.
 */
public struct Argument: Hashable {
    let name: String
    let type: String
    let hash: String
    let value: AnyCodable?

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
    public init<S: Hashable>(name: String, type: String, value: S) {
        // Argument information
        self.name = name
        self.type = type

        // Argument hash identifier.
        let hashableValue = HashableValue(value: value, type: type)
        hash = hashableValue.hashValue.hash

        /* Encode value */
        if let value = value as? OptionalArgumentProtocol, !value.hasValue {
            self.value = nil
        } else {
            self.value = AnyCodable(value)
        }
    }

    // MARK: Hashable Value

    /*
     We use hashable value struct to make sure that fields with same values
     but different paths or names don't collide in the variables.

     Hash takes into account the type of the parameter and its value. It may
     happen that two unrelated fields with same values share a value, even
     though they are completely unrelated in business logic.
     */
    struct HashableValue<S: Hashable>: Hashable {
        let value: S
        let type: String
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(hash)
    }
}

// MARK: - Hashing

extension Array where Element == Argument {
    /// Returns the hash of the collection of arguments.
    var hash: String { hashValue.hash }
}
