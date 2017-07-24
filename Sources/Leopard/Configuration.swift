import class Foundation.FileManager
import Cheetah

/// A basic (empty) config file
public protocol Config : Decodable {}

/// HTTP Server configuration.
///
/// Useful when the HTTP post and host need to be customized
public protocol HTTPServerConfig : Config {
    /// The HTTP port to serve the website on
    ///
    /// Defaults to `80`
    var port: UInt16 { get }
    
    /// The hostname/IP address to serve HTTP on
    ///
    /// Serves on all hosts and addresses by default or `0.0.0.0`
    var hostname: String { get }
}

/// HTTP routing configuration.
///
/// Allows customization of the prefix token
public protocol RoutingConfig : Config {
    /// The token to prefix parameters with
    ///
    /// Defaults to `:`
    var routingToken: String? { get }
}

extension Config {
    /// Deserializes the configuration file from JSON
    public static func decodeFromJSON(atPath path: String) throws -> Self? {
        guard let data = FileManager.default.contents(atPath: path) else {
            throw LeopardConfigError.fileDoesNotExist(atPath: path)
        }
        
        let object = try JSONObject(from: data)
        
        return try JSONDecoder().decode(Self.self, from: object)
    }
}

/// Leopard's default configuration errors
public enum LeopardConfigError : Error, CustomDebugStringConvertible {
    /// The routing token is invalid
    ///
    /// It may only be a single character long
    case invalidRoutingToken(String)
    
    /// The file at the given path does not exist
    case fileDoesNotExist(atPath: String)
    
    public var debugDescription: String {
        switch self {
        case .invalidRoutingToken(let token):
            return "The token may only be one character long, contained \"\(token)\""
        case .fileDoesNotExist(let path):
            return "The file at the following path did not exist: \"\(path)\""
        }
    }
}
