

/// Errors that occur during the parsing of the schema.
public enum ParsingError: Error {
    /// Schema references a type that doesn't exist in the schema.
    case unknownType(String)
    
    /// Schema references an unknown scalar.
    case unknownScalar(String)
    
    /// Schema references an object that is not in the schema.
    case unknownObject(String)
    
    /// Schema references an unknown input object.
    case unknownInputObject(String)
}
