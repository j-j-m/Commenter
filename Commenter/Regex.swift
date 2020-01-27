//
//  Regex.swift
//  Commenter
//
//  Created by Jacob Martin on 1/26/20.
//  Copyright © 2020 Jacob Martin. All rights reserved.
//

import Foundation

struct Regex: ExpressibleByStringLiteral, Equatable {

    fileprivate let expression: NSRegularExpression

    init(stringLiteral: String) {
        do {
            self.expression = try NSRegularExpression(pattern: stringLiteral, options: [])
        } catch {
            print("Failed to parse (stringLiteral) as a regular expression")
            self.expression = try! NSRegularExpression(pattern: ".*", options: [])
        }
    }

    fileprivate func match(_ input: String) -> Bool {
        let result = expression.rangeOfFirstMatch(in: input, options: [],
                                                  range: NSRange(input.startIndex..., in: input))
        return !NSEqualRanges(result, NSMakeRange(NSNotFound, 0))
    }
}

extension Regex {
    static func ~=(pattern: Regex, value: String) -> Bool {
        return pattern.match(value)
    }
}
