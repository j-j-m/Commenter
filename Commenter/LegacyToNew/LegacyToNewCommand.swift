//
//  SourceEditorCommand.swift
//  Commenter
//
//  Created by Jacob Martin on 7/7/18.
//  Copyright © 2018 Jacob Martin. All rights reserved.
//

import Foundation
import XcodeKit

enum MatchType: Regex {
    case start = #"^/\*\*"#
    case end = #"\*/$"#
    case both = #"\/\*\*.*\*\/"#
}

func matchType(for string: String) -> MatchType? {
    switch string {
    case MatchType.both.rawValue:
        return MatchType.both
    case MatchType.start.rawValue:
        return MatchType.start
    case MatchType.end.rawValue:
        return MatchType.end
    default:
        return nil
    }
}

// MARK: - Source Editor Command
class LegacyToNewCommand: NSObject, XCSourceEditorCommand {
    
    private var isInComment: Bool = false
    
    var indicesToRemove = [Int]()
    
    fileprivate func augmentSingleLine(_ invocation: XCSourceEditorCommandInvocation, with start: Int) {
        if var s = invocation.buffer.lines[start] as? String {
//            let indentation = s.leadingEmptyRegion
            
            guard let matchType = matchType(for: s) else {
                s = s.replacingOccurrences(of: #"^\s\*"#, with: " ", options: [.regularExpression])
                if isInComment {
                    invocation.buffer.lines[start] = #"/// "# + s
                }
                return
            }
            
            if matchType == .end {
                isInComment = false
            }
            
            s = s.replacingOccurrences(of: #"^/\*\*"#, with: "", options: [.regularExpression])
            s = (isInComment || matchType == .both ? #"/// "# : "") + s.replacingOccurrences(of: #"\*/$"#, with: "", options: [.regularExpression])
            invocation.buffer.lines[start] = s
            
            
            if matchType == .start {
                indicesToRemove.append(start)
                isInComment = true
            }
            if matchType == .end {
                indicesToRemove.append(start)
            }
        }
        
        print(indicesToRemove)
    }

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
            
            for i in (0..<invocation.buffer.lines.count) {
                augmentSingleLine(invocation, with: i)
            }
        
        invocation.buffer.lines.removeObjects(at: IndexSet(indicesToRemove))
        completionHandler(nil)
    }
}
