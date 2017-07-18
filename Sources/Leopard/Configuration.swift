import class Foundation.FileManager
import Cheetah

public protocol Config : Decodable {}

public protocol HTTPServerConfig : Config {
    var port: UInt16 { get }
    var hostname: String { get }
}

public protocol RoutingConfig : Config {
    var routingToken: String? { get }
}

extension Config {
    public static func decodeFromJSON(atPath path: String) throws -> Self? {
        guard let data = FileManager.default.contents(atPath: path) else {
            throw LeopardConfigError.fileDoesNotExist(atPath: path)
        }
        
        let object = try JSONObject(from: data)
        
        return try JSONDecoder().decode(Self.self, from: object)
    }
}

public enum LeopardConfigError : Error {
    case invalidRoutingToken(String)
    case fileDoesNotExist(atPath: String)
}
