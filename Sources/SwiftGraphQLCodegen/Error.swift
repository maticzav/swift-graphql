import Foundation

/// Errors that might occur during the code-generation phase.
public enum CodegenError: Error {
    
    /// There was a problem with the formatting of the library.
    case formatting(Error)
}
