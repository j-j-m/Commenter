//
//  SourceEditorCommand.swift
//  Commenter
//
//  Created by Jacob Martin on 7/7/18.
//  Copyright © 2018 Jacob Martin. All rights reserved.
//

import Foundation
import XcodeKit

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

// MARK: - Source Editor Command
class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        if invocation.commandIdentifier.contains("FormatMarkdown") {
            
            var lastCommentLine = 0
            
            var currentStart: Int?
            
            while lastCommentLine < invocation.buffer.lines.count {
                let currentLine = invocation.buffer.lines[lastCommentLine] as! String
                
                if currentLine.hasPrefix("///") {
        
                    if currentStart == nil {
                        currentStart = lastCommentLine
                    }
                    
                } else {
                    if let start = currentStart {
                        let range = (start...lastCommentLine)
                        let rangeArray = [Int](range)
                        var mapped = range.enumerated().map({ (index, element) -> String in
                            
                            let s = invocation.buffer.lines[element] as! String
                            return s.replacingOccurrences(of: "///", with: index == 0 ? "/**" : "")
                        })
                        
                        range.forEach {
                            invocation.buffer.lines[$0] = mapped.dequeue()
                        }
                        if let end = rangeArray.last {
                            invocation.buffer.lines.insert("*/", at: end)
                        }
                        currentStart = nil
                    }
                }
                
                lastCommentLine += 1
            }
            
        }
        
        completionHandler(nil)
    }
    
}
