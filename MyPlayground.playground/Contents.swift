import Cocoa

var str = "/** Hello, playground"
str.replacingOccurrences(of: #"^/\*\*"#, with: "", options: [.regularExpression])
