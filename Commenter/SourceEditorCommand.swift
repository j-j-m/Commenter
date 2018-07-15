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

// MARK: - Source Editor Command
class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    fileprivate func augmentSingleLine(_ invocation: XCSourceEditorCommandInvocation, _ start: Int) {
        if let s = invocation.buffer.lines[start] as? String {
            let indentation = s.leadingEmptyRegion
            invocation.buffer.lines[start] = s.replacingOccurrences(of: "///", with: "")
            invocation.buffer.lines.insert(indentation + "*/", at: start + 1)
            invocation.buffer.lines.insert(indentation + "/**", at: start)
        }
    }
    
    fileprivate func augmentBlock(_ start: Int, _ lastCommentLine: Int, _ invocation: XCSourceEditorCommandInvocation) {
        // block comment
        
        let range = (start...lastCommentLine)
        let rangeArray = [Int](range)
        var mapped = range.enumerated().map({ (index, element) -> String in
            
            let s = invocation.buffer.lines[element] as! String
            return s.replacingOccurrences(of: "///", with: "")
        })
        
        range.forEach {
            invocation.buffer.lines[$0] = mapped.dequeue()
        }
        if let end = rangeArray.last,
            let line = invocation.buffer.lines[end] as? String {
            
            let indentation = line.leadingEmptyRegion
            
            invocation.buffer.lines.insert(indentation + "*/", at: end)
            invocation.buffer.lines.insert(indentation + "/**", at: start)
        }
    }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        if invocation.commandIdentifier.contains("FormatMarkdown") {
            
            var lastCommentLine = 0
            
            var currentStart: Int?
            
            guard let regex = try? NSRegularExpression(pattern: "///", options: NSRegularExpression.Options.caseInsensitive) else {
               return
            }
            
            while lastCommentLine < invocation.buffer.lines.count {
                let currentLine = invocation.buffer.lines[lastCommentLine] as! String
                
                let matchCount = regex.numberOfMatches(in: currentLine, options: [], range: NSMakeRange(0, currentLine.count))
                if matchCount > 0 {
                    
                    if currentStart == nil {
                        currentStart = lastCommentLine
                    }
                    
                    if let start = currentStart, start == invocation.buffer.lines.count - 1 {
                        // single line comment
                        augmentSingleLine(invocation, start)
                        currentStart = nil
                    }
                    
                } else {
                    
                    if let start = currentStart {
                
                        if lastCommentLine - start == 1 {
                            // single line comment
                            
                            augmentSingleLine(invocation, start)
                            
                        } else {
                            augmentBlock(start, lastCommentLine, invocation)
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
