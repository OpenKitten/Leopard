open class Config : Decodable {}

public protocol RoutingConfig {
    var routingToken: String? { get }
}

public enum LeopardConfigError : Error {
    case invalidRoutingToken(String)
}
