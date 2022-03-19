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
        let lines = source.split(separator: "\n")
        
        var codeWithInlineTest: [String] = []
        
        for index in lines.indices {
            let content = String(lines[index])
            
            if index < line {
                codeWithInlineTest.append(content)
            }
            
            if index == line {
                let indentation = content.countLeft(characters: CharacterSet.whitespaces) + 3
                
                codeWithInlineTest.append(content.replacingOccurrences(
                    of: ".assertInlineSnapshot()",
                    with: #".assertInlineSnapshot(""""#
                ))
                codeWithInlineTest.append(contentsOf: self
                    .split(separator: "\n")
                    .map { String($0) }
                    .map { $0.indent(by: indentation) })
                codeWithInlineTest.append(#"""")"#)
            }
            
            if index > line {
                codeWithInlineTest.append(content)
            }
        }
        
        let code = codeWithInlineTest.joined(separator: "\n")
        try! code.write(to: sourcepath, atomically: true, encoding: .utf8)
        
        XCTFail("Wrote Inline Snapshot", file: file, line: line)
    }

    /// Returns the number of characters before reaching a character that's not in a set going left-to-right.
    func countLeft(characters: CharacterSet) -> Int {
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
    func indent(by spaces: Int) -> String {
        "\(String(repeating: " ", count: spaces))\(self)"
    }
}
