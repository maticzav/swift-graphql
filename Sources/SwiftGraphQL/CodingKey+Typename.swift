import Foundation

extension CodingKey {
    public var isTypenameKey: Bool {
        self.stringValue == "__typename"
    }
}
