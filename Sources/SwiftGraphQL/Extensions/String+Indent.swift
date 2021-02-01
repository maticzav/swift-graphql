/*
 Utility functions for handling indentation in the generated code.
 */

extension String {
    /// Returns an indented string by n spaces in front.
    func indent(by level: Int) -> String {
        "\(String(repeating: " ", count: level))\(self)"
    }
}

extension Collection where Element == String {
    /// Indents every element of the list by level.
    func indent(by level: Int) -> [String] {
        map { $0.indent(by: level) }
    }
}
