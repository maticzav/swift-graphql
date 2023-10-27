import XCTest

/// Checks whether the provided `body` throws an `error` of the given `error`'s type
func XCTAssertThrowsError<T: Swift.Error, Output>(
    of: T.Type,
    file: StaticString = #file,
    line: UInt = #line,
    _ body: () async throws -> Output
) async {
    do {
        _ = try await body()
        XCTFail("body completed successfully", file: file, line: line)
    } catch let error {
        XCTAssertNotNil(error as? T, "Expected error of \(T.self), got \(type(of: error))")
    }
}
