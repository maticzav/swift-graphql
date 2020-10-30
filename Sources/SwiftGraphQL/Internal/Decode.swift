import Foundation

/// Represents values identifieable by the hash of the value.
public struct HashMap {
    private var data = [Key:Any]()
    
    public init() {}

    private struct Key: Hashable {
        let key: String
        let hash: String
    }

    // MARK: - Accessors

    /// Sets the scalar to specific index.
    public mutating func set(key: String, hash: String, value: Any) {
        let index = Key(key: key, hash: hash)
        data[index] = value
    }

    public subscript<Value>(keyed: String) -> [String: Value] {
        get {
            var map = [String: Value]()

            self.data.forEach {
                let (key, value) = $0

                // Filter out the types with a different key and cast down.
                if key.key == keyed {
                    map[key.hash] = (value as! Value)
                }
            }

            return map
        }
    }
}
