import Foundation

extension Collection {
    /// Returns a mapped instance of each value.
    func indexMap<T>(fn: ((offset: Int, element: Self.Element)) throws -> T) rethrows -> [T] {
        try enumerated().map(fn)
    }
}
