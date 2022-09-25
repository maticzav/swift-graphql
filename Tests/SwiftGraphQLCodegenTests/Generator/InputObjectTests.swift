@testable import GraphQLAST
@testable import SwiftGraphQLCodegen
import XCTest

final class InputObjectTests: XCTestCase {
    
    func testInputObjectField() throws {
        let type = InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                InputValue(
                    name: "id",
                    description: "Field description.\nMultiline.",
                    type: .nonNull(.named(.inputObject("AnotherInputObject")))
                ),
                /* Scalar, Docs */
                InputValue(
                    name: "input_value",
                    description: nil,
                    type: .named(.scalar("ID"))
                ),
            ]
        )
        
        let generated = try type.declaration(
            context: Context.from(scalars: ["ID": "ID"])
        ).format()
        
        print(generated)

        generated.assertInlineSnapshot(matching: """
           extension InputObjects {
             public struct InputObject: Encodable, Hashable {

               /// Field description.
               /// Multiline.
               public var id: InputObjects.AnotherInputObject

               public var inputValue: OptionalArgument<ID>

               public init(
                 id: InputObjects.AnotherInputObject,
                 inputValue: OptionalArgument<ID> = .init()
               ) {
                 self.id = id
                 self.inputValue = inputValue
               }

               public func encode(to encoder: Encoder) throws {
                 var container = encoder.container(keyedBy: CodingKeys.self)
                 try container.encode(id, forKey: .id)
                 if inputValue.hasValue { try container.encode(inputValue, forKey: .inputValue) }
               }

               public enum CodingKeys: String, CodingKey {
                 case id = "id"
                 case inputValue = "input_value"
               }
             }
           }
           """)
    }

    func testEnumField() throws {
        let type = InputObjectType(
            name: "InputObject",
            description: nil,
            inputFields: [
                /* Scalar, Docs */
                InputValue(
                    name: "id",
                    description: "Field description.",
                    type: .nonNull(.named(.enum("ENUM")))
                ),
            ]
        )

        let generated = try type.declaration(
            context: Context.from(scalars: ["ID": "String"])
        ).format()

        generated.assertInlineSnapshot(matching: """
           extension InputObjects {
             public struct InputObject: Encodable, Hashable {
           
               /// Field description.
               public var id: Enums.Enum
           
               public init(
                 id: Enums.Enum
               ) {
                 self.id = id
               }
           
               public func encode(to encoder: Encoder) throws {
                 var container = encoder.container(keyedBy: CodingKeys.self)
                 try container.encode(id, forKey: .id)
               }
           
               public enum CodingKeys: String, CodingKey {
                 case id = "id"
               }
             }
           }
           """)
    }
}
