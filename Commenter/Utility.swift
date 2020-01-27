//
//  Utility.swift
//  Commenter
//
//  Created by Jacob Martin on 1/26/20.
//  Copyright © 2020 Jacob Martin. All rights reserved.
//

import Foundation

// MARK: - Array Queue Extension
extension Array {
    
    mutating func enqueue(newElement: Element) {
        self.append(newElement)
    }
    
    mutating func dequeue() -> Element? {
        return self.remove(at: 0)
    }
    
    func peekAtQueue() -> Element? {
        return self.first
    }
}

extension String {
    var leadingEmptyRegion: String {
        do {
            let regex = try NSRegularExpression(pattern: " *", options: NSRegularExpression.Options.caseInsensitive)
            guard let r = regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count))?.range,
                let range = Range(r, in: self) else {
                    return ""
            }
            
            return String(self[range])
        } catch {
            return ""
        }
    }
}
