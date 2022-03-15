import Foundation
import XCTest

/// Creates a snapshot test for a value.
func assertSnapshot(
    matching any: Any,
    file: StaticString = #file,
    function: String = #function,
    line: UInt = #line)
{
    var snapshot = ""
    dump(any, to: &snapshot)
    
    let snapshotDirectoryUrl = URL(fileURLWithPath: "\(file)")
        .deletingPathExtension()
    
    let snapshotFileUrl = snapshotDirectoryUrl
        .appendingPathComponent(function)
        .appendingPathExtension("txt")
    
    let fileManager = FileManager.default
    try! fileManager.createDirectory(at: snapshotDirectoryUrl, withIntermediateDirectories: true)
    
    if fileManager.fileExists(atPath: snapshotFileUrl.path) {
        let reference = try! String(contentsOf: snapshotFileUrl, encoding: .utf8)
        XCTAssertEqual(reference, snapshot, file: file, line: line)
    } else {
        try! snapshot.write(to: snapshotFileUrl, atomically: true, encoding: .utf8)
        XCTFail("Wrote snapshot:\n\n\(snapshot)", file: file, line: line)
    }
}
