
class Logger {
    static func info(_ message: String) {
        print("\n\("🌟".greenColor) \(message)\n")
    }
    
    static func error(_ message: String) {
        print("\n\("🚨".redColor) \(message)\n")
    }
    
    static func separator() {
        print("\n\("-----------------------------".yellowColor)\n")
    }
    
    static func prettyPrintJSON(from data: Data) {
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            info("✅ Response received:\n\(prettyString)")
        } else {
            info("✅ Response received (raw):\n\(String(data: data, encoding: .utf8) ?? "❌ Invalid UTF-8")")
        }
        separator()
    }
}

extension String {
    var redColor: String { return "\u{001B}[0;31m\(self)\u{001B}[0;39m" }
    var greenColor: String { return "\u{001B}[0;32m\(self)\u{001B}[0;39m" }
    var yellowColor: String { return "\u{001B}[0;33m\(self)\u{001B}[0;39m" }
    var blueColor: String { return "\u{001B}[0;34m\(self)\u{001B}[0;39m" }
}
