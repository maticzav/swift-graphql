import Foundation

/* Types */

struct Car: Codable {
    let name: String
    let brand: String
}


/* Prototype */

struct Data: Codable {
    /* Properties */
    
    var string = [String: String]()
    var car = [String: Car]()
    
    /* Generated */
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        
        // Decode each key.
        var map = HashMap()
        
        for codingKey in container.allKeys {
            
            let (key, hash) = codingKey.stringValue.unhash()
            
            switch key {
            case "string":
                let value = try container.decode(String.self, forKey: codingKey)
                map.set(key: key, hash: hash, value: value)
            case "car":
                let value = try container.decode(Car.self, forKey: codingKey)
                map.set(key: key, hash: hash, value: value)
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unknown key \(key)."
                    )
                )
            }
        }
        
        // Assign values.
        self.string = map["string"]
        self.car = map["car"]
    }
    
    private struct DynamicCodingKeys: CodingKey {
        // Use for string-keyed dictionary
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        // Use for integer-keyed dictionary
        var intValue: Int?
        init?(intValue: Int) { nil }
    }
}


// MARK: - HashMap

/// Represents values identifieable by the hash of the value.
struct HashMap {
    var data = [Key:Any]()
    
    struct Key: Hashable {
        let key: String
        let hash: String
    }
    
    // MARK: - Accessors
    
    /// Sets the scalar to specific index.
    mutating func set(key: String, hash: String, value: Any) {
        let index = Key(key: key, hash: hash)
        data[index] = value
    }
    
    subscript<Value>(keyed: String) -> [String: Value] {
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

// MARK: - String Hashing extension

extension String {
    fileprivate func unhash() -> (key: String, hash: String) {
        let parts = self.split(separator: "_")
        
        let key = String(parts[0])
        let hash = String(parts[1])
        
        return (key, hash)
    }
}


/* Goal */

let json = """
{
    "string_hash1": "value",
    "string_hash2": "value",
    "car_hash1": {
        "brand": "Audi",
        "name": "A4"
    }
}
""".data(using: .utf8)!

let decoder = JSONDecoder()
let value = try! decoder.decode(Data.self, from: json)

print(value)
