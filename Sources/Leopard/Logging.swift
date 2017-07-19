public enum LogLevel : String, CustomDebugStringConvertible {
    case verbose, debug, info, warning, error
    
    public var debugDescription: String {
        return self.rawValue
    }
}

public protocol Logger {
    func log(_ entity: Encodable, level: LogLevel)
}

import Cheetah

public class JSONLogger : Logger {
    let closure: ((String) -> ())
    
    public init(_ closure: @escaping ((String) -> ())) {
        self.closure = closure
    }
    
    public static var print: JSONLogger {
        return JSONLogger {
            Swift.print($0)
        }
    }
    
    public func log(_ entity: Encodable, level: LogLevel) {
        do {
            let entity = try JSONEncoder().encode(entity).serializedString()
            closure(level.rawValue + ": " + entity)
        } catch {
            Swift.print("Unable to log entity since it fails JSON Encoding")
            Swift.print(entity)
        }
    }
}
