/// Log levels
///
/// Contains multiple levels of importance
public enum LogLevel : String, CustomDebugStringConvertible {
    /// Verbose is used for logging every single detail
    case verbose
    
    /// Debug is used for logging useful debug information
    case debug
    
    /// Info is used for informing messages such that is not used for debugging, but isn't a problem, either.
    case info
    
    /// A warning, it should be given attention but isn't a real problem (yet)
    case warning
    
    /// An error has occurred
    case error
    
    /// A fatal error has occurred, severely impacting the quality of this service
    case fatal
    
    public var debugDescription: String {
        return self.rawValue
    }
}

/// Accepts log messages
public protocol Logger {
    /// Logs the entity with the given log level
    func log(_ entity: Encodable, level: LogLevel)
}

// MARK - JSON Logging

import Cheetah

/// Logs message as JSON to the provided destination
public class JSONLogger : Logger {
    let closure: ((String) -> ())
    
    /// Creates a new JSONLogger and provides a closure to call with the JSON String.
    public init(_ closure: @escaping ((String) -> ())) {
        self.closure = closure
    }
    
    /// Logs all messsages as JSON to the console
    public static var print: JSONLogger {
        return JSONLogger {
            Swift.print($0)
        }
    }
    
    /// Logs the entity as JSON to the closure, prefixed by the log level
    public func log(_ entity: Encodable, level: LogLevel) {
        do {
            if let entity = try JSONEncoder().encode(value: entity) {
                closure(level.rawValue + ": " + entity.serializedString())
                return
            }
        } catch {}
        
        Swift.print("Unable to log entity since it fails JSON Encoding")
        Swift.print(entity)
    }
}
