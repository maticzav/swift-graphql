import Foundation
import SwiftGraphQL

// This file is a playground of types. There are no tests, but it
// should always compile!

let searchresult = Selection.SearchResult {
    try $0.on(
        character: Selection.Character { try $0.name() },
        comic: Selection.Comic { try $0.title() }
    )
}

let query = Selection.Query {
    try $0.search(query: Inputs.Search(query: ""), selection: searchresult.list)
}

