import Foundation
import XCTest

extension String {
    
    /// Creates an inline snapshot of a the result.
    func assertInlineSnapshot(
        matching: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard matching == nil else {
            XCTAssertEqual(self, matching)
            return
        }
        
        let sourcepath = URL(fileURLWithPath: "\(file)")
        
        let source = try! String(contentsOf: sourcepath)
        let lines = source.split(omittingEmptySubsequences: false, whereSeparator: { $0.isNewline })
        
        var codeWithInlineTest: [String] = []
        
        for index in lines.indices {
            // Line values start with 1, indexes start with 0.
            let normalizedIndex = index + 1
            
            let content = String(lines[index])
            
            if normalizedIndex < line {
                codeWithInlineTest.append(content)
            }
            
            if normalizedIndex == line {
                let indentation = content.countLeft(characters: CharacterSet.whitespaces) + 3
                
                codeWithInlineTest.append(content.replacingOccurrences(
                    of: ".assertInlineSnapshot()",
                    with: #".assertInlineSnapshot(matching: """"#
                ))
                codeWithInlineTest.append(contentsOf: self
                    .replacingOccurrences(of: #"""""#, with: #"\"\"\""#)
                    .split(separator: "\n", omittingEmptySubsequences: false)
                    .map { String($0) }
                    .map { $0.indent(by: indentation) })
                codeWithInlineTest.append(#"""")"#.indent(by: indentation))
            }
            
            if normalizedIndex > line {
                codeWithInlineTest.append(content)
            }
        }
        
        let code = codeWithInlineTest.joined(separator: "\n")
        try! code.write(to: sourcepath, atomically: true, encoding: .utf8)
        
        XCTFail("Wrote Inline Snapshot", file: file, line: line)
    }

    /// Returns the number of characters before reaching a character that's not in a set going left-to-right.
    private func countLeft(characters: CharacterSet) -> Int {
        var count = 0
        
        for char in self {
            if char.unicodeScalars.allSatisfy({ characters.contains($0) }) {
                count += 1
            } else {
                return count
            }
        }
        
        return count
    }
    
    /// Returns an indented string by n spaces in front.
    private func indent(by spaces: Int) -> String {
        "\(String(repeating: " ", count: spaces))\(self)"
    }
}
