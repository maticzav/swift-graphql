import Foundation
import SwiftGraphQL

struct DateTime: Codec {
    private var data: Date
    var raw: Int

    init(from date: Date) {
        data = date
        raw = Int(date.timeIntervalSince1970)
    }

    // MARK: - Public interface

    var value: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr")
        formatter.setLocalizedDateFormatFromTemplate("dd-MM-yyyy")

        return formatter.string(from: data)
    }

    // MARK: - Codec conformance

    // MARK: - Decoder

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)

        data = Date(timeIntervalSince1970: TimeInterval(value))
        raw = value
    }

    // MARK: - Encoder

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Int(data.timeIntervalSince1970))
    }

    // MARK: - Mock value

    static var mockValue = DateTime(from: Date())
}
