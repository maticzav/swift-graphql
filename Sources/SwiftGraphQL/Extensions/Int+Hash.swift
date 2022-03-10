import Foundation

extension Int {
    /// Returns the condensed representation of a string that only contains alpha-numeric characters.
    ///
    /// - Note: We convert the integer hash value to a higher number system to shorten the hash,
    ///         and replace the sign (i.e. negation) with an underscore so that it
    ///         conforms to alpha-numeric restriction.
    var hash: String {
        let hash = String(self, radix: 36)
        let normalized = hash.replacingOccurrences(of: "-", with: "_")

        return normalized
    }
}
