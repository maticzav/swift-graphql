import Foundation

/*
 The following algorithm is inspired by JSONEncoder's snake casing
 internal function. Its main goal is to cleverly convert GraphQL field- and type-
 names to a Swift format.
 */

extension String {
    // MARK: - Public properties

    // Returns the string PascalCased.
    var pascalCase: String {
        let specialChars = CharacterSet.alphanumerics.inverted
        let upperCaseChars = CharacterSet.uppercaseLetters
        let lowerCaseChars = CharacterSet.lowercaseLetters
        let upperDelimiters = CharacterSet().union(specialChars).union(upperCaseChars)
        let lowerDelimiters = CharacterSet().union(specialChars).union(lowerCaseChars)

        // This algorithm is heavily inspired by JSONEncoder's `_convertToSnakeCase` function in Swift source code.
        var words = [Range<String.Index>]()

        var wordStart = startIndex
        var searchRange: Range<String.Index> = wordStart ..< endIndex

        while let delimiterRange = rangeOfCharacter(from: upperDelimiters, options: [], range: searchRange) {
            let range = wordStart ..< delimiterRange.lowerBound

            // We hit a special character. If there's something to capture, capture it.
            // Move one up and continue in the next cycle.
            guard self[delimiterRange.lowerBound].isLetter else {
                if !range.isEmpty { words.append(range) }
                wordStart = index(after: range.upperBound)
                searchRange = wordStart ..< searchRange.upperBound
                continue
            }

            // We know that we hit an uppercase character.
            // Set the word start to that character, and search from the next character onwards.
            wordStart = delimiterRange.lowerBound
            searchRange = index(after: wordStart) ..< searchRange.upperBound

            if !range.isEmpty {
                words.append(range)
            }

            // If there are no more lower delimiters. Just end here and append all the remaining uppercase characters.
            guard let lowerCaseRange = rangeOfCharacter(from: lowerDelimiters, options: [], range: searchRange) else {
                break
            }

            // We found the next small character delimiter. If it comes right after the current character,
            // we should take care of it in the next cycle.
            // Otherwise, we should take everything up to the next lowercase character.
            let nextCharacterAfterDelimiter = index(after: delimiterRange.lowerBound)
            if lowerCaseRange.lowerBound == nextCharacterAfterDelimiter {
                continue
            } else {
                // There was a range of >1 capital letters. Turn those into a word, stopping at the capital before the lower case character.
                words.append(wordStart ..< lowerCaseRange.lowerBound)

                // Next word starts at the capital before the lowercase we just found
                wordStart = index(after: lowerCaseRange.lowerBound)
                searchRange = wordStart ..< searchRange.upperBound
            }
        }

        let remaining = wordStart ..< searchRange.upperBound
        if !remaining.isEmpty {
            // Append the last part of the word.
            words.append(remaining)
        }

        let result = words.map { self[$0].capitalized }.joined()
        return result
    }

    // Returns the string camelCased.
    var camelCase: String {
        let pascal = pascalCase
        return pascal[pascal.startIndex].lowercased() + pascal.dropFirst()
    }
}
