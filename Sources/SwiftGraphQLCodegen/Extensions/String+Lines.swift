import Foundation

extension Collection where Element == String {
    /// Returns a collection of strings, each string in new line.
    var lines: String {
        joined(separator: "\n")
    }
}
