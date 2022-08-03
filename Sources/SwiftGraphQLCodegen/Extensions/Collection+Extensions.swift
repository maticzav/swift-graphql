import Foundation

extension Collection {
    /// Returns a list of unique items.
    ///
    /// - Note: Item's uniqueness is determined by the hash value of that item.
    ///         If there are more items with the same hash, we use the last one.
    func unique<T>(by: (Element) -> T) -> [Element] where T: Hashable {
        var dict = [T: Element]()

        for item in self {
            dict[by(item)] = item
        }

        return [Element](dict.values)
    }
    
    /// Returns a mapped instance of each value.
    func indexMap<T>(fn: ((offset: Int, element: Self.Element)) throws -> T) rethrows -> [T] {
        try enumerated().map(fn)
    }
}
