//
//  File.swift
//  
//
//  Created by Matic Zavadlal on 11/10/2020.
//

import Foundation

extension Collection where Element == String {
    var lines: String {
        self.joined(separator: "\n")
    }
}
