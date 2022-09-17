@testable import GraphQLAST
@testable import SwiftGraphQLCodegen

import XCTest

final class EnumTests: XCTestCase {
    func testGenerateEnum() throws {
        /* Declaration */

        let type = EnumType(
            name: "Episodes",
            description: "Collection of all StarWars episodes.\nEarliest trilogy.",
            enumValues: [
                EnumValue(
                    name: "NEWHOPE",
                    description: "Released in 1977.",
                    isDeprecated: false,
                    deprecationReason: nil
                ),
                EnumValue(
                    name: "EMPIRE",
                    description: "Introduced Yoda.\nConsidered the best.",
                    isDeprecated: false,
                    deprecationReason: nil
                ),
                EnumValue(
                    name: "JEDI",
                    description: "Released in 1983.",
                    isDeprecated: true,
                    deprecationReason: "Was too good."
                ),
                EnumValue(
                    name: "SKYWALKER",
                    description: nil,
                    isDeprecated: true,
                    deprecationReason: nil
                ),
            ]
        )

        let generated = try type.declaration.format()

        generated.assertInlineSnapshot(matching: """
           extension Enums {
             /// Collection of all StarWars episodes.
             /// Earliest trilogy.
             public enum Episodes: String, CaseIterable, Codable {
               /// Released in 1977.
               case newhope = "NEWHOPE"
               /// Introduced Yoda.
               /// Considered the best.
               case empire = "EMPIRE"
               /// Released in 1983.
               case jedi = "JEDI"
           
               case skywalker = "SKYWALKER"
             }
           }
           
           extension Enums.Episodes: GraphQLScalar {
             public init(from data: AnyCodable) throws {
               switch data.value {
               case let string as String:
                 if let value = Enums.Episodes(rawValue: string) {
                   self = value
                 } else {
                   throw ScalarDecodingError.unknownEnumCase(value: string)
                 }
               default:
                 throw ScalarDecodingError.unexpectedScalarType(
                   expected: "Episodes",
                   received: data.value
                 )
               }
             }
           
             public static var mockValue = Self.newhope
           }
           """)
    }
}
