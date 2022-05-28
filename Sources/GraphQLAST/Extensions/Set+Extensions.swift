import Foundation

extension Set {
    /// Inserts the element into the set without modifying the old set and returns the new value.
    func inserting(_ element: Element) -> Set<Element> {
        var copy = self
        copy.insert(element)
        return copy
    }
}
